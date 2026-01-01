# /// script
# requires-python = ">=3.13"
# dependencies = []
# ///

import os
import sys
import subprocess
import re
import glob
from pathlib import Path
import tomllib


# libclang search directories per platform
LIBCLANG_SEARCH_DIRS = {
    "linux": [
        "/usr/lib",
        "/usr/lib/llvm-*/lib",
        "/usr/lib/x86_64-linux-gnu",
        "/usr/lib/aarch64-linux-gnu",
        "/usr/local/lib",
        "/usr/local/llvm/lib",
    ],
    "darwin": [
        "/usr/local/opt/llvm/lib",
        "/opt/homebrew/opt/llvm/lib",
        "/Library/Developer/CommandLineTools/usr/lib",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib",
    ],
    "win32": [
        "C:/Program Files/LLVM/bin",
        "C:/Program Files/LLVM/lib",
        "C:/msys64/mingw64/bin",
        "C:/msys64/mingw64/lib",
        "C:/msys64/clang64/bin",
        "C:/msys64/clang64/lib",
    ],
}

# libclang filename patterns per platform
LIBCLANG_FILE_PATTERNS = {
    "linux": ["libclang.so", "libclang-*.so", "libclang.so.*", "libclang-*.so.*"],
    "darwin": ["libclang.dylib", "libclang.*.dylib"],
    "win32": ["libclang.dll", "clang.dll"],
}


def parse_libclang_version(filename: str) -> list[int]:
    """Extract version components from libclang filename."""
    if match := re.search(r"libclang\.so\.(.+)$", filename):
        version_str = match.group(1)
    elif match := re.search(r"libclang-(.+)\.so", filename):
        version_str = match.group(1)
    elif match := re.search(r"libclang\.(.+)\.dylib", filename):
        version_str = match.group(1)
    else:
        return []

    parts = []
    for part in version_str.split("."):
        try:
            parts.append(int(part))
        except ValueError:
            parts.append(0)
    return parts


def find_libclang() -> tuple[Path, str] | None:
    """Find the best libclang shared library.

    Returns (directory, filename) tuple or None if not found.
    """
    # Collect search directories
    dirs = []
    if libclang_path := os.environ.get("LIBCLANG_PATH"):
        for p in libclang_path.split(os.pathsep):
            path = Path(p)
            if path.is_dir():
                dirs.append(path)

    for pattern in LIBCLANG_SEARCH_DIRS.get(sys.platform, []):
        for match in glob.glob(pattern):
            path = Path(match)
            if path.is_dir():
                dirs.append(path)

    # Search for libclang files
    results = []
    file_patterns = LIBCLANG_FILE_PATTERNS.get(sys.platform, [])
    for directory in dirs:
        for pattern in file_patterns:
            for match_path in glob.glob(str(directory / pattern)):
                path = Path(match_path)
                if path.is_file():
                    version = parse_libclang_version(path.name)
                    results.append((directory, path.name, version))

    if not results:
        return None

    # Select best version (highest version, first found as tiebreaker)
    best = max(reversed(results), key=lambda x: x[2])
    return (best[0], best[1])


def get_libclang_link_name(filename: str) -> str:
    """Get linker name from filename (strips 'lib' prefix and extensions)."""
    name = filename
    if name.startswith("lib"):
        name = name[3:]
    for ext in [".dylib", ".so", ".dll"]:
        if ext in name:
            name = name[:name.find(ext)]
            break
    return name


class LdFlagsBuilder:
    """Builder for constructing LDFLAGS with proper spacing and escaping."""

    def __init__(self):
        self._flags: list[str] = []

    def add(self, *flags: str) -> "LdFlagsBuilder":
        """Add one or more flags."""
        for flag in flags:
            if flag and flag.strip():
                self._flags.append(flag.strip())
        return self

    def add_lib(self, lib: str, static: bool = False) -> "LdFlagsBuilder":
        """Add a library link flag."""
        if static:
            self._flags.append(f"-l:{lib}")
        else:
            self._flags.append(f"-l{lib}")
        return self

    def add_lib_path(self, path: str) -> "LdFlagsBuilder":
        """Add a library search path."""
        self._flags.append(f"-L{path}")
        return self

    def add_group(self, *libs: str) -> "LdFlagsBuilder":
        """Add libraries wrapped in --start-group/--end-group."""
        self._flags.append("--start-group")
        for lib in libs:
            if lib and lib.strip():
                self._flags.append(lib.strip())
        self._flags.append("--end-group")
        return self

    def build(self) -> str:
        """Build the final LDFLAGS string."""
        flags_str = " ".join(self._flags)
        return f'--link-options="{flags_str}"'


def root_dir():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    return os.path.dirname(script_dir)


def libclang_dir():
    return os.path.join(root_dir(), 'lib', 'libclang')


def cpp_lds():
    return os.path.join(root_dir(), 'scripts', 'cpp.lds')


def run_llvm_config(*args):
    llvm_config_path = os.path.join(libclang_dir(), 'bin', 'llvm-config')
    if sys.platform == "win32":
        llvm_config_path += ".exe"

    if not os.path.isfile(llvm_config_path):
        raise FileNotFoundError(
            f"The llvm-config executable was not found at {llvm_config_path}")

    cmd = [llvm_config_path] + list(args)

    try:
        output = subprocess.check_output(
            cmd,
            text=True,
            stderr=subprocess.STDOUT
        )
        return output.strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            f"Command {cmd} failed with output:\n{e.output}") from e
    
def read_version():
    cjpm_toml = os.path.join(root_dir(), "cjpm.toml")
    with open(cjpm_toml, "rb") as f:
        data = tomllib.load(f)
    return data["package"]["version"]


def is_static_libclang():
    """Check if STATIC_LIBCLANG env var is set to 'true'."""
    return os.environ.get("STATIC_LIBCLANG", "").lower() == "true"


def preprocess_environment(env):
    builder = LdFlagsBuilder()
    libdir = run_llvm_config("--libdir")
    debug = "-g" in sys.argv
    static = is_static_libclang()

    # Strip flag (non-debug mode)
    if not debug and sys.platform != "darwin":
        builder.add("--strip-all")

    # Library search path
    builder.add_lib_path(libdir)

    # Platform-specific flags
    match sys.platform:
        case "darwin":
            builder.add("-search_paths_first", "-headerpad_max_install_names")
        case "linux":
            builder.add("--gc-sections", "--gc-keep-exported", f"-T {cpp_lds()}")

    # System libs
    system_libs = run_llvm_config("--system-libs")

    # Build library list for grouping (non-darwin)
    libs = []
    libs.extend(system_libs.split())

    if static:
        # Static LLVM libs
        static_libs = run_llvm_config("--link-static", "--libs")
        for lib in static_libs.split():
            lib_name = lib[2:]  # strip -l
            if sys.platform != "darwin":
                libs.append(f"-l:lib{lib_name}.a")
            else:
                libs.append(lib)

        # Static libclang libs
        libdir_path = Path(os.path.join(libclang_dir(), "lib"))
        for lib in libdir_path.glob("libclang*.a"):
            lib_name = lib.stem
            if sys.platform != "darwin":
                libs.append(f"-l:{lib_name}.a")
            else:
                libs.append(f"-l{lib_name[3:]}")  # strip 'lib' prefix
    else:
        # Dynamic libclang - search for library
        found = find_libclang()
        if found:
            libclang_path, libclang_filename = found
            print(f"Found libclang: {libclang_path / libclang_filename}", flush=True)
            builder.add_lib_path(str(libclang_path))
            link_name = get_libclang_link_name(libclang_filename)
            libs.append(f"-l{link_name}")
        else:
            # Fallback to default names
            print("Warning: libclang not found, using default link names", flush=True)
            match sys.platform:
                case "win32":
                    libs.append("-l:libclang.dll.a")
                case _:
                    libs.append("-lclang")

    # C++ runtime
    match sys.platform:
        case "win32":
            if static:
                libs.extend(["-l:libstdc++.a", "-l:libwinpthread.a", "-lmingwex", "-lmsvcrt", "-lversion"])
            else:
                libs.extend(["-lstdc++", "-lwinpthread", "-lmingwex", "-lmsvcrt", "-lversion"])
        case "darwin":
            libs.extend(["-lc++", "-lc++abi", "-lSystem"])
        case "linux":
            if static:
                libs.extend(["-l:libstdc++.a", "-lgcc_s"])
            else:
                libs.extend(["-lstdc++", "-lgcc_s"])

    # Add with grouping for non-darwin
    if sys.platform != "darwin":
        builder.add_group(*libs)
    else:
        builder.add(*libs)

    ldflags = builder.build()

    env["LDFLAGS"] = ldflags
    print("ldflags:", ldflags, flush=True)
    env["CJBIND_VERSION"] = read_version()

    return env


def main():
    base_env = os.environ.copy()
    processed_env = preprocess_environment(base_env)

    command = ["cjpm"] + sys.argv[1:]

    process = subprocess.run(
        command,
        env=processed_env,
        stdin=sys.stdin,
        stdout=sys.stdout,
        stderr=sys.stderr,
    )

    sys.exit(process.returncode)


if __name__ == "__main__":
    main()
