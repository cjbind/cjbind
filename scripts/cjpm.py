
import os
import sys
import subprocess

def run_llvm_config(*args):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.dirname(script_dir)
    llvm_config_path = os.path.join(parent_dir, 'lib', 'libclang', 'bin', 'llvm-config')
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

CLANG_LIBS = [
    "clang",
    "clangAST",
    "clangAnalysis",
    "clangBasic",
    "clangDriver",
    "clangEdit",
    "clangExtractAPI",
    "clangFrontend",
    "clangIndex",
    "clangLex",
    "clangParse",
    "clangRewrite",
    "clangSema",
    "clangSerialization",
    "clangTooling",
]

def preprocess_environment(env):
    ldflags = run_llvm_config("--ldflags", "--system-libs", "--libs", "core", "support", "target", "targetparser")
    ldflags = ldflags.replace("\n", " ")

    for lib in CLANG_LIBS:
        ldflags += f" -l{lib}"

    env["LDFLAGS"] = ldflags
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