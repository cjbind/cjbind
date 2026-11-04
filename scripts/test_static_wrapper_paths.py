#!/usr/bin/env python3
"""Verify bridge files survive sequential and concurrent CLI generation."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
import os
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cli", type=Path)
    args = parser.parse_args()
    cli = args.cli.resolve() if args.cli else ROOT / "target/release/bin" / (
        "cjbind_cli.exe" if os.name == "nt" else "cjbind_cli"
    )
    if not cli.is_file():
        raise RuntimeError(f"build the CLI first: {cli}")

    with tempfile.TemporaryDirectory(prefix="cjbind-wrapper-paths-") as temp:
        directory = Path(temp)
        environment = os.environ.copy()
        for name in ("TMPDIR", "TEMP", "TMP"):
            environment[name] = str(directory)
        former_default = directory / "cjbind/extern.c"
        former_default.parent.mkdir()
        former_default.write_text("preserve unrelated bridge", encoding="utf-8")

        def invoke(header: Path, *options: str) -> subprocess.CompletedProcess[str]:
            result = subprocess.run(
                [str(cli), str(header), "--wrap-static-fns", "--no-detect-include-path",
                 "--no-layout-test", *options],
                cwd=ROOT, env=environment, capture_output=True, text=True,
                encoding="utf-8", errors="replace", timeout=120,
            )
            return result

        def generate(index: int) -> tuple[Path, str]:
            name = f"wrapper_value_{index}"
            extension = ".hpp" if index % 2 else ".h"
            header = directory / (name + extension)
            header.write_text(f"static inline int {name}(void) {{ return {index}; }}\n", encoding="utf-8")
            # Different extensions sharing the same stem must not share a bridge.
            output = directory / f"bindings.case{index}"
            result = invoke(header, "-o", str(output))
            if result.returncode:
                raise AssertionError(result.stderr)
            bridge = Path(str(output) + (".cpp" if extension == ".hpp" else ".c"))
            if f"{name}__extern" not in output.read_text(encoding="utf-8"):
                raise AssertionError(f"missing binding for {name}")
            return bridge, name

        generated = [generate(0), generate(1)]
        with ThreadPoolExecutor(max_workers=4) as pool:
            generated.extend(pool.map(generate, range(2, 10)))
        for bridge, name in generated:
            source = bridge.read_text(encoding="utf-8")
            if f"{name}__extern" not in source:
                raise AssertionError(f"bridge was overwritten: {bridge}")

        header = directory / "wrapper_value_0.h"
        missing_path = invoke(header)
        if missing_path.returncode == 0 or "--wrap-static-fns-path" not in missing_path.stderr:
            raise AssertionError("stdout generation must explain the required explicit bridge path")
        explicit_base = directory / "custom.generated"
        explicit = invoke(header, "--wrap-static-fns-path", str(explicit_base))
        if explicit.returncode or "wrapper_value_0__extern" not in explicit.stdout:
            raise AssertionError(f"explicit path with stdout failed: {explicit.stderr}")
        if "wrapper_value_0__extern" not in explicit_base.with_suffix(".c").read_text(encoding="utf-8"):
            raise AssertionError("explicit bridge path was not preserved")
        if former_default.read_text(encoding="utf-8") != "preserve unrelated bridge":
            raise AssertionError("generation touched the former shared temporary path")
    print("Static wrapper paths: sequential, concurrent, explicit, and stdout cases passed")


if __name__ == "__main__":
    main()
