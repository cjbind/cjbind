#!/usr/bin/env python3
"""Execute generated bitfield helpers against an independent bit-by-bit oracle."""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HEADER = ROOT / "cjbind_test/testdata/headers/bitfield-full-word-width.h"
RUNTIME = ROOT / "cjbind_test/runtime/bitfield_main.cj"


def run(command: list[str], *, cwd: Path) -> None:
    print("+ " + " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def find_cjbind() -> Path:
    executable = "cjbind_cli.exe" if os.name == "nt" else "cjbind_cli"
    for profile in ("release", "debug"):
        candidate = ROOT / "target" / profile / "bin" / executable
        if candidate.is_file():
            return candidate
    raise RuntimeError("build cjbind_cli first or provide --cjbind")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cjbind", type=Path)
    parser.add_argument("--keep-temps", action="store_true")
    args = parser.parse_args()
    binary = args.cjbind.resolve() if args.cjbind else find_cjbind()
    temp_root = Path(tempfile.mkdtemp(prefix="cjbind-bitfield-runtime-"))
    failed = False
    try:
        generated = temp_root / "bindings.cj"
        run([
            str(binary), "--no-detect-include-path", "--no-layout-test",
            "-o", str(generated), str(HEADER),
        ], cwd=ROOT)
        output = temp_root / ("bitfield-test.exe" if os.name == "nt" else "bitfield-test")
        run([
            "cjc", str(generated), str(RUNTIME), "--static", "-Woff", "unused",
            "-o", str(output),
        ], cwd=ROOT)
        run([str(output)], cwd=temp_root)
    except (subprocess.CalledProcessError, OSError):
        failed = True
        print(f"Bitfield runtime test files kept at {temp_root}", file=sys.stderr)
        raise
    finally:
        if not args.keep_temps and not failed:
            shutil.rmtree(temp_root, ignore_errors=True)


if __name__ == "__main__":
    main()
