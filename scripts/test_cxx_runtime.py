#!/usr/bin/env python3
"""Link and execute the generated C++ lifecycle binding."""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "cjbind_test/runtime"
GENERATED = ROOT / "cjbind_test/testdata/expected/cxx-runtime-lifecycle.cj"


def run(command: list[str], *, cwd: Path) -> None:
    print("+ " + " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def find_cxx() -> str:
    requested = os.environ.get("CXX")
    if requested:
        return requested
    for candidate in ("clang++", "g++"):
        located = shutil.which(candidate)
        if located:
            return located
    raise RuntimeError("a C++14 compiler is required (set CXX to its executable)")


def executable_name() -> str:
    return "cxx-runtime-test.exe" if os.name == "nt" else "cxx-runtime-test"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--keep-temps", action="store_true")
    args = parser.parse_args()

    if not GENERATED.exists():
        raise RuntimeError("generated lifecycle binding is missing; run the snapshot tests first")

    temp_root = Path(tempfile.mkdtemp(prefix="cjbind-cxx-runtime-"))
    failed = False
    try:
        object_path = temp_root / ("cxx_lifecycle.obj" if os.name == "nt" else "cxx_lifecycle.o")
        run(
            [
                find_cxx(),
                "-std=c++14",
                "-fno-exceptions",
                "-fno-rtti",
                "-c",
                str(FIXTURE / "cxx_lifecycle.cpp"),
                "-o",
                str(object_path),
            ],
            cwd=ROOT,
        )

        output = temp_root / executable_name()
        run(
            [
                "cjc",
                str(GENERATED),
                str(FIXTURE / "main.cj"),
                f"--link-option={object_path}",
                "--static",
                "-Woff",
                "unused",
                "-o",
                str(output),
            ],
            cwd=ROOT,
        )
        run([str(output)], cwd=temp_root)
    except subprocess.CalledProcessError:
        failed = True
        print(f"C++ runtime test files kept at {temp_root}", file=sys.stderr)
        raise
    finally:
        if not args.keep_temps and not failed:
            shutil.rmtree(temp_root, ignore_errors=True)


if __name__ == "__main__":
    main()
