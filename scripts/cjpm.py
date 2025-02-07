
import os
import sys
import subprocess
from pathlib import Path


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


def preprocess_environment(env):
    ldflags = ""
    libdir = run_llvm_config("--libdir")

    debug = "-g" in sys.argv

    match sys.platform:
        case "win32":
            ldflags += f"-L{libdir}"
            if not debug:
                ldflags = "--strip-all " + ldflags
        case "darwin":
            ldflags += f"-L{libdir} -search_paths_first -headerpad_max_install_names"
        case "linux":
            ldflags += f"--gc-sections -L{libdir} -T {cpp_lds()}"
            if not debug:
                ldflags = "--strip-all " + ldflags

    ldflags += " "

    if sys.platform != "darwin":
        ldflags += "--start-group "

    ldflags += run_llvm_config("--system-libs", "--libs")
    ldflags = ldflags.replace("\n", " ")

    libdir = Path(os.path.join(libclang_dir(), "lib"))

    for lib in libdir.glob("libclang*.a"):
        lib_name = lib.stem
        if lib_name.startswith("lib"):
            lib_name = lib_name[3:]
        ldflags += f" -l{lib_name} "

    match sys.platform:
        case "win32":
            ldflags += " -l:libstdc++.a -lversion "
        case "darwin":
            ldflags += " -lc++ -lc++abi -lSystem "
        case "linux":
            ldflags += " -l:libstdc++.a -lgcc_s "

    if sys.platform != "darwin":
        ldflags += "--end-group"

    env["LDFLAGS"] = ldflags
    print("ldflags:", ldflags, flush=True)

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
