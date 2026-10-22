#!/usr/bin/env python3
"""Check that concurrent generators keep macro fallback values and files isolated."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import threading


ROOT = Path(__file__).resolve().parents[1]
VALUE = re.compile(r"\bCONCURRENT_VALUE_(\d+)\s*:\s*\w+\s*=\s*(\d+)")


def find_cjbind() -> Path:
    executable = "cjbind_cli.exe" if os.name == "nt" else "cjbind_cli"
    for profile in ("release", "debug"):
        candidate = ROOT / "target" / profile / "bin" / executable
        if candidate.is_file():
            return candidate
    raise RuntimeError("build cjbind_cli first or provide --cjbind")


def run_round(
    binary: Path, temp_root: Path, language: str, round_id: int,
    workers: int, macro_count: int,
) -> None:
    # All processes share the same system temp root, as normal CLI invocations do.
    # Different values under identical header/macro names reveal cross-process PCH use.
    environment = os.environ.copy()
    scratch = temp_root / "shared-temp"
    environment.update({name: str(scratch) for name in ("TMP", "TEMP", "TMPDIR")})
    barrier = threading.Barrier(workers)

    def generate(worker: int) -> str | None:
        directory = temp_root / f"{language}-{round_id}-{worker}"
        directory.mkdir()
        header = directory / ("same.h" if language == "c" else "same.hpp")
        expected = {index: (worker + 1) * 1000 + index for index in range(macro_count)}
        header.write_text("".join(
            f"#define CONCURRENT_VALUE_{index} ({value})\n"
            for index, value in expected.items()
        ), encoding="utf-8")
        output = directory / "bindings.cj"
        barrier.wait(timeout=30)
        try:
            result = subprocess.run([
                str(binary), "--no-detect-include-path", "--no-layout-test",
                "-o", str(output), str(header), "--", "-x", language,
            ], cwd=ROOT, env=environment, capture_output=True, text=True,
                encoding="utf-8", errors="replace", timeout=90)
        except subprocess.TimeoutExpired:
            return f"worker {worker}: timed out"
        (directory / "stdout.txt").write_text(result.stdout, encoding="utf-8")
        (directory / "stderr.txt").write_text(result.stderr, encoding="utf-8")
        if result.returncode:
            return f"worker {worker}: exit status {result.returncode}"
        if not output.is_file():
            return f"worker {worker}: no generated output"
        actual = {int(index): int(value) for index, value in
                  VALUE.findall(output.read_text(encoding="utf-8"))}
        for index, value in expected.items():
            if actual.get(index) != value:
                return (f"worker {worker}: CONCURRENT_VALUE_{index} expected "
                        f"{value}, got {actual.get(index)!r}")
        return None

    with ThreadPoolExecutor(max_workers=workers) as executor:
        errors = [error for error in executor.map(generate, range(workers)) if error]
    if errors:
        raise RuntimeError(f"{language} round {round_id}: " + "; ".join(errors))
    leftovers = list(scratch.iterdir())
    if leftovers:
        raise RuntimeError(f"fallback temporary files were not cleaned: {leftovers}")
    print(f"{language} round {round_id}: {workers} generators, "
          f"{macro_count} exact macro values each; temporary directory empty", flush=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cjbind", type=Path)
    parser.add_argument("--workers", type=int, default=8)
    parser.add_argument("--rounds", type=int, default=3)
    parser.add_argument("--macro-count", type=int, default=64)
    parser.add_argument("--keep-temps", action="store_true")
    args = parser.parse_args()
    if min(args.workers, args.rounds, args.macro_count) < 1:
        parser.error("workers, rounds, and macro-count must be positive")
    binary = args.cjbind.resolve() if args.cjbind else find_cjbind()
    temp_root = Path(tempfile.mkdtemp(prefix="cjbind-fallback-concurrency-")).resolve()
    (temp_root / "shared-temp").mkdir()
    failed = False
    try:
        for language in ("c", "c++"):
            # Establish the fixture's expected values before exercising concurrency.
            run_round(binary, temp_root, language, 0, 1, args.macro_count)
            for round_id in range(1, args.rounds + 1):
                run_round(binary, temp_root, language, round_id,
                          args.workers, args.macro_count)
    except (RuntimeError, OSError):
        failed = True
        print(f"Macro fallback test files kept at {temp_root}", file=sys.stderr)
        raise
    finally:
        if not args.keep_temps and not failed:
            # This is exactly the absolute, unique directory created above.
            if not temp_root.is_absolute() or temp_root.resolve() != temp_root:
                raise RuntimeError(f"refusing to clean unexpected temp path: {temp_root}")
            shutil.rmtree(temp_root)


if __name__ == "__main__":
    main()
