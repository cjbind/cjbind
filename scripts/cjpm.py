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


def find_gcc_lib_path():
    """Find the directory containing libgcc.a using gcc."""
    try:
        # Try finding libgcc using gcc
        output = subprocess.check_output(
            ["gcc", "-print-libgcc-file-name"],
            text=True,
            stderr=subprocess.DEVNULL
        ).strip()
        # The output is likely a path like .../libgcc.a
        # We need to make sure we're getting a valid path
        path = Path(output)
        if path.is_file():
            return str(path.parent)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    return None


def get_runtime_libs(platform_name: str, dynamic: bool) -> list[str]:
    """Return platform runtime libraries for the selected link mode."""
    match platform_name:
        case "win32":
            if dynamic:
                # Dynamic Windows builds use system libclang from the MSYS2 MINGW64 environment,
                # which is still paired with GCC runtime libraries in CI.
                return ["-lgcc_s", "-lwinpthread", "-lmingwex", "-lmsvcrt", "-lversion"]
            # Static Windows builds use llvm-mingw-built libclang.
            return ["-l:libc++.a", "-lclang_rt-builtins", "-lunwind", "-lucrt", "-ldbghelp", "-lshlwapi", "-lversion"]
        case "darwin":
            return ["-lc++", "-lc++abi", "-lSystem"]
        case "linux":
            if dynamic:
                return ["-lstdc++", "-lgcc_s"]
            return ["-l:libstdc++.a", "-l:libgcc.a", "-l:libgcc_eh.a"]
        case _:
            return []


def should_add_gcc_lib_path(platform_name: str, dynamic: bool) -> bool:
    """Return whether the wrapper should add GCC's library directory to LDFLAGS."""
    return platform_name == "win32" and dynamic


def ensure_codecvt_shim(libclang_lib_dir: str) -> str | None:
    """Build a shim providing std::__1::codecvt<char,char,_Mbstatet>::id.

    The llvm-mingw-built libclang references this symbol, but Cangjie's libc++
    defines mbstate_t as int so its codecvt uses <char,char,int> instead.
    We synthesize a tiny static library with the missing symbol.
    """
    if sys.platform != "win32":
        return None

    shim_lib = os.path.join(libclang_lib_dir, "libcjbind_codecvt_shim.a")
    if os.path.exists(shim_lib):
        return "-l:libcjbind_codecvt_shim.a"

    clang_exe = os.path.join(libclang_lib_dir, "..", "bin", "clang.exe")
    ar_exe = os.path.join(libclang_lib_dir, "..", "bin", "llvm-ar.exe")
    if not os.path.exists(clang_exe) or not os.path.exists(ar_exe):
        print("Warning: clang/llvm-ar not found in libclang, cannot create codecvt shim",
              flush=True)
        return None

    import tempfile
    with tempfile.TemporaryDirectory() as tmpdir:
        src = os.path.join(tmpdir, "codecvt_shim.c")
        obj = os.path.join(tmpdir, "codecvt_shim.o")

        with open(src, "w") as f:
            f.write(
                "// Shim: std::__1::codecvt<char,char,_Mbstatet>::id\n"
                "// Cangjie libc++ maps mbstate_t to int; llvm-mingw maps it to _Mbstatet.\n"
                "// locale::id = {once_flag(4B) + int32_t(4B)} = 8 bytes, align 4, zero-init.\n"
                "// Verified against Cangjie libc++.a: .bss section size 0x08, align 2**2.\n"
                "__attribute__((aligned(4)))\n"
                "char _ZNSt3__17codecvtIcc9_MbstatetE2idE[8];\n"
            )

        subprocess.run(
            [clang_exe, "-c", "-target", "x86_64-w64-mingw32", src, "-o", obj],
            check=True,
        )
        subprocess.run([ar_exe, "rcs", shim_lib, obj], check=True)

    print(f"Created codecvt shim: {shim_lib}", flush=True)
    return "-l:libcjbind_codecvt_shim.a"


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


def parse_wrapper_args(args: list[str]) -> tuple[list[str], bool]:
    """Extract wrapper-only flags and return arguments to forward to cjpm."""
    forwarded_args: list[str] = []
    use_static = False

    for arg in args:
        if arg == "--static":
            use_static = True
            continue
        forwarded_args.append(arg)

    return forwarded_args, use_static


def read_passes_cache() -> str | None:
    """Read cached optimization passes from scripts/.passes_cache."""
    cache_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), '.passes_cache')
    if os.path.exists(cache_file):
        with open(cache_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    return None


def preprocess_environment(env, cjpm_args: list[str], use_static: bool):
    builder = LdFlagsBuilder()
    debug = "-g" in cjpm_args
    dynamic = not use_static

    # Print build mode info
    link_mode = "dynamic" if dynamic else "static"
    build_mode = "debug" if debug else "release"
    print(f"Build mode: {build_mode}, Link mode: {link_mode} (platform: {sys.platform})", flush=True)

    # Set CJBIND_OPT_PASSES from cache
    passes = read_passes_cache()
    if passes:
        env["CJBIND_OPT_PASSES"] = passes
        print(f"Set CJBIND_OPT_PASSES from cache: {passes[:80]}...", flush=True)
    else:
        print("Warning: .passes_cache not found, opt wrapper may fail", flush=True)

    # Strip flag (release mode only, not on darwin)
    if not debug and sys.platform != "darwin":
        builder.add("--strip-all")

    # Library search path (only for static linking)
    if not dynamic:
        libdir = run_llvm_config("--libdir")
        builder.add_lib_path(libdir)

    # Dynamic Windows builds still depend on GCC runtime libraries from MSYS2.
    if should_add_gcc_lib_path(sys.platform, dynamic):
        gcc_lib_path = find_gcc_lib_path()
        if gcc_lib_path:
            builder.add_lib_path(gcc_lib_path)

    # Platform-specific flags
    match sys.platform:
        case "darwin":
            builder.add("-search_paths_first", "-headerpad_max_install_names")
        case "linux":
            # Skip gc-sections in debug mode to preserve debug info
            if not debug:
                builder.add("--gc-sections", "--gc-keep-exported")
            if not dynamic:
                builder.add(f"-T{cpp_lds()}")

    # Build library list for grouping (non-darwin)
    libs = []

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
        # Static linking: use llvm-config to get system libs and LLVM libs
        system_libs = run_llvm_config("--system-libs")
        libs.extend(system_libs.split())

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

    # On static Windows builds, inject a shim for the codecvt ABI mismatch
    if not dynamic:
        shim_flag = ensure_codecvt_shim(os.path.join(libclang_dir(), "lib"))
        if shim_flag:
            libs.append(shim_flag)

    runtime_libs = get_runtime_libs(sys.platform, dynamic)

    print(f"Runtime libs: {' '.join(runtime_libs)}", flush=True)
    libs.extend(runtime_libs)

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
    cjpm_args, use_static = parse_wrapper_args(sys.argv[1:])
    processed_env = preprocess_environment(base_env, cjpm_args, use_static)

    command = ["cjpm"] + cjpm_args

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
