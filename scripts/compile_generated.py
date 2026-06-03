#!/usr/bin/env python3
"""Compile selected generated bindings with cjpm.

This smoke test catches invalid Cangjie output that snapshot tests can miss,
such as duplicate declarations or generated helper names that are not valid
identifiers.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HEADERS = [
    ROOT / "cjbind_test/testdata/headers/union_with_nesting.h",
    ROOT / "cjbind_test/testdata/headers/union_with_zero_sized_array.h",
    ROOT / "cjbind_test/testdata/headers/tomlc17-issue19.h",
]


def run(cmd: list[str], *, cwd: Path, env: dict[str, str] | None = None) -> None:
    printable = " ".join(str(part) for part in cmd)
    print(f"+ {printable}", flush=True)
    subprocess.run(cmd, cwd=cwd, env=env, check=True)


def build_cli() -> Path:
    run(
        [sys.executable, "scripts/cjpm.py", "--static", "build", "-m", "cjbind_cli", "-V"],
        cwd=ROOT,
    )
    exe = "cjbind_cli.exe" if os.name == "nt" else "cjbind_cli"
    candidates = [
        ROOT / "target/release/bin" / exe,
        ROOT / "target/debug/bin" / exe,
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    raise RuntimeError(f"failed to locate built {exe}")


def write_smoke_project(project: Path, generated: str) -> None:
    (project / "src").mkdir(parents=True)
    (project / "cangjie-sdk.toml").write_text(
        '[toolchain]\nchannel = "nightly"\n',
        encoding="utf-8",
    )
    (project / "cjpm.toml").write_text(
        """[package]
  cjc-version = "1.1.0"
  compile-option = "-Woff unused"
  name = "cjbind_ffi"
  output-type = "static"
  version = "0.0.0"
""",
        encoding="utf-8",
    )
    (project / "src/wrap.cj").write_text(generated, encoding="utf-8")


def compile_header(cli: Path, header: Path, keep_temps: bool) -> None:
    temp_root = Path(tempfile.mkdtemp(prefix=f"cjbind-smoke-{header.stem}-"))
    failed = False
    try:
        out = temp_root / "generated.cj"
        run(
            [
                str(cli),
                str(header),
                "-o",
                str(out),
                "--package",
                "cjbind_ffi",
                "--no-detect-include-path",
                "--",
                "--target=x86_64-unknown-linux-gnu",
            ],
            cwd=ROOT,
        )

        project = temp_root / "project"
        write_smoke_project(project, out.read_text(encoding="utf-8"))
        run(["cjpm", "build", "--target-dir", str(temp_root / "target"), "-V"], cwd=project)
    except subprocess.CalledProcessError as exc:
        failed = True
        print(f"compile smoke failed for {header}", file=sys.stderr)
        print(f"temporary files kept at {temp_root}", file=sys.stderr)
        raise SystemExit(exc.returncode) from exc
    finally:
        if not keep_temps and not failed:
            shutil.rmtree(temp_root, ignore_errors=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--keep-temps", action="store_true")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    if sys.platform != "linux" and not args.force:
        print("generated binding compile smoke is currently Linux-only")
        return

    if args.skip_build:
        exe = "cjbind_cli.exe" if os.name == "nt" else "cjbind_cli"
        cli = ROOT / "target/release/bin" / exe
        if not cli.exists():
            cli = ROOT / "target/debug/bin" / exe
        if not cli.exists():
            raise RuntimeError(f"{cli} does not exist; rerun without --skip-build")
    else:
        cli = build_cli()

    for header in HEADERS:
        compile_header(cli, header, args.keep_temps)


if __name__ == "__main__":
    main()
