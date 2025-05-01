import subprocess

import os
import tempfile
import sys


def main():
    # get from arguments
    o_level = "O2"
    if len(sys.argv) > 1:
        o_level = sys.argv[1] 
    

    cangjie_home = os.getenv("CANGJIE_HOME")
    if not cangjie_home:
        raise EnvironmentError("CANGJIE_HOME environment variable is not set.")
    
    with tempfile.TemporaryFile() as temp_file:
        ret = subprocess.check_output(
            [
                os.path.join(cangjie_home, "third_party", "llvm", "bin", "opt.exe"),
                "--print-pipeline-passes",
                "--cangjie-pipeline",
                f"-passes=default<{o_level}>",
                "--only-verify-out",
                temp_file.name,
            ],
            stderr=subprocess.STDOUT,
            text=True,
        )
        print(ret)


if __name__ == "__main__":
    main()