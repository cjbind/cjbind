
import os
import sys
import subprocess
from pathlib import Path



def libclang_dir():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.dirname(script_dir)
    return os.path.join(parent_dir, 'lib', 'libclang')

def run_llvm_config(*args):
    llvm_config_path = os.path.join(libclang_dir(), 'bin', 'llvm-config')
    if sys.platform == "win32":
        llvm_config_path += ".exe"
    
    if not os.path.isfile(llvm_config_path):
        raise FileNotFoundError(f"The llvm-config executable was not found at {llvm_config_path}")
    
    cmd = [llvm_config_path] + list(args)
    
    try:
        output = subprocess.check_output(
            cmd,
            text=True,
            stderr=subprocess.STDOUT
        )
        return output.strip()
    except subprocess.CalledProcessError as e:
        raise RuntimeError(f"Command {cmd} failed with output:\n{e.output}") from e


def preprocess_environment(env):
    ldflags = ""
    libdir = run_llvm_config("--libdir")

    match sys.platform:
        case "win32":
            ldflags += f"-L{libdir}"
            cj_home = os.environ["CANGJIE_HOME"]
            tools_dir = Path(cj_home) / "tools" / "bin"
            ldflags += f" -L{str(tools_dir)}" # for stdc++
        case "darwin":
            ldflags += f"-L{libdir} -search_paths_first -headerpad_max_install_names"
        case "linux":
            ldflags += f"-L{libdir}"

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
            ldflags += " -lstdc++ -lversion "
        case "darwin":
            ldflags += " -lc++ -lc++abi -lSystem "
        case "linux":
            ldflags += " -lstdc++ -lgcc_s "

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