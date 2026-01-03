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

if sys.platform == "win32":
    import ctypes
    from ctypes import wintypes

    _GetShortPathNameW = ctypes.windll.kernel32.GetShortPathNameW
    _GetShortPathNameW.argtypes = [wintypes.LPCWSTR, wintypes.LPWSTR, wintypes.DWORD]
    _GetShortPathNameW.restype = wintypes.DWORD

    def get_short_path(path: str) -> str:
        """Get Windows 8.3 short path name to avoid spaces."""
        buf_size = _GetShortPathNameW(path, None, 0)
        if buf_size == 0:
            return path  # Fallback to original path
        buf = ctypes.create_unicode_buffer(buf_size)
        _GetShortPathNameW(path, buf, buf_size)
        return buf.value
else:
    def get_short_path(path: str) -> str:
        """No-op on non-Windows platforms."""
        return path


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


def is_dev_symlink(filename: str) -> bool:
    """Check if filename is a development symlink (ends with .so, .dylib, or .dll without version suffix)."""
    # Development symlinks: libclang.so, libclang-15.so (no version after .so)
    # Runtime libraries: libclang.so.15, libclang-15.so.15.0.0
    if filename.endswith(".so") or filename.endswith(".dylib") or filename.endswith(".dll"):
        return True
    return False


def find_libclang() -> tuple[Path, str, bool] | None:
    """Find the best libclang shared library.

    Returns (directory, filename, is_dev_symlink) tuple or None if not found.
    The is_dev_symlink flag indicates if the file is a proper .so/.dylib/.dll file
    that can be linked with -l flag, vs a versioned runtime library that needs -l: syntax.
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
    dev_results = []  # Development symlinks (.so files)
    versioned_results = []  # Versioned runtime libraries (.so.X files)
    file_patterns = LIBCLANG_FILE_PATTERNS.get(sys.platform, [])
    for directory in dirs:
        for pattern in file_patterns:
            for match_path in glob.glob(str(directory / pattern)):
                path = Path(match_path)
                if path.is_file():
                    version = parse_libclang_version(path.name)
                    if is_dev_symlink(path.name):
                        dev_results.append((directory, path.name, version))
                    else:
                        versioned_results.append((directory, path.name, version))

    # Prefer development symlinks (they can be linked with -l flag)
    # Use max without reversed to prefer earlier-found entries (LIBCLANG_PATH first)
    if dev_results:
        best = max(dev_results, key=lambda x: x[2])
        return (best[0], best[1], True)

    # Fall back to versioned libraries (need -l: syntax)
    if versioned_results:
        best = max(versioned_results, key=lambda x: x[2])
        return (best[0], best[1], False)

    return None


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
        # Convert to short path on Windows if path contains spaces
        if " " in path:
            path = get_short_path(path)
        self._flags.append(f"-L{path}")
        return self

    def add_lib_file(self, path: str) -> "LdFlagsBuilder":
        """Add a library file by full path."""
        # Convert to short path on Windows if path contains spaces
        if " " in path:
            path = get_short_path(path)
        self._flags.append(path)
        return self

    def add_group(self, *libs: str) -> "LdFlagsBuilder":
        """Add libraries wrapped in --start-group/--end-group."""
        self._flags.append("--start-group")
        for lib in libs:
            if lib and lib.strip():
                lib = lib.strip()
                # Convert to short path on Windows if lib is a path with spaces
                if " " in lib:
                    lib = get_short_path(lib)
                self._flags.append(lib)
        self._flags.append("--end-group")
        return self

    def build(self) -> str:
        """Build the final LDFLAGS string."""
        return " ".join(self._flags)


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
    cjpm_toml = os.path.join(root_dir(), "cjbind_cli", "cjpm.toml")
    with open(cjpm_toml, "rb") as f:
        data = tomllib.load(f)
    return data["package"]["version"]


def is_dynamic_libclang():
    """Check if dynamic linking should be used (LINK_MODE env var, default: static, options: static/dynamic)."""
    return os.environ.get("LINK_MODE", "static").lower() == "dynamic"


def preprocess_environment(env):
    builder = LdFlagsBuilder()
    libdir = run_llvm_config("--libdir")
    debug = "-g" in sys.argv
    dynamic = is_dynamic_libclang()

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
            builder.add("--gc-sections", "--gc-keep-exported", f"-T{cpp_lds()}")

    # System libs
    system_libs = run_llvm_config("--system-libs")

    # Build library list for grouping (non-darwin)
    libs = []
    libs.extend(system_libs.split())

    if dynamic:
        # Dynamic libclang - search for library and link directly by full path
        found = find_libclang()
        if found:
            libclang_path, libclang_filename, is_dev = found
            full_path = str(libclang_path / libclang_filename)
            print(f"Found libclang: {full_path} (dev_symlink={is_dev})", flush=True)
            # Directly specify the library file path
            libs.append(full_path)

            # Add DLL directory to PATH in GitHub Actions (Windows only)
            if sys.platform == "win32":
                github_path = os.environ.get("GITHUB_PATH")
                if github_path:
                    with open(github_path, "a", encoding="utf-8") as f:
                        f.write(str(libclang_path) + "\n")
                    print(f"Added to GITHUB_PATH: {libclang_path}", flush=True)
        else:
            # Fallback to default names
            print("Warning: libclang not found, using default link names", flush=True)
            match sys.platform:
                case "win32":
                    libs.append("-l:libclang.dll.a")
                case _:
                    libs.append("-lclang")
    else:
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

    # C++ runtime
    match sys.platform:
        case "win32":
            if dynamic:
                libs.extend(["-lstdc++", "-lwinpthread", "-lmingwex", "-lmsvcrt", "-lversion"])
            else:
                libs.extend(["-l:libstdc++.a", "-lwinpthread", "-lmingwex", "-lmsvcrt", "-lversion"])
        case "darwin":
            libs.extend(["-lc++", "-lc++abi", "-lSystem"])
        case "linux":
            if dynamic:
                libs.extend(["-lstdc++", "-lgcc_s"])
            else:
                libs.extend(["-l:libstdc++.a", "-lgcc_s"])

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
