#!/usr/bin/env python3
"""Check constant values and reject mutable storage or truncated wide integers."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile

from compile_generated import ROOT, build_cli
from test_macro_const_types import require_declaration, run


HEADER = ROOT / "cjbind_test/testdata/headers/support/ir/constant-values.h"
MODES = [
    ("default", []),
    ("fit", ["--fit-macro-constants"]),
    ("precise", ["--macro-const-use-ctypes"]),
    ("combined", ["--macro-const-use-ctypes", "--fit-macro-constants"]),
]
SKIPPED = [
    "MUTABLE_INTEGER", "MUTABLE_FLOAT", "MUTABLE_BYTES", "MUTABLE_POINTER",
    "VOLATILE_INTEGER", "VOLATILE_BYTES", "VOLATILE_ALIAS",
    "WIDE_HIGH", "WIDE_LOW", "WIDE_SMALL",
]

# Independent IEEE representations, checked after compiling the bindings.
FLOAT_VALUES = {
    "MACRO_SMALL": ("Float64", 0x3E7AD7F29ABCAF48),
    "MACRO_PI": ("Float64", 0x400921FB54442D18),
    "MACRO_ZERO": ("Float64", 0),
    "MACRO_NEG_ZERO": ("Float64", 0x8000000000000000),
    "MACRO_MIN_SUB": ("Float64", 1),
    "CONST_SMALL": ("Float64", 0x3E7AD7F29ABCAF48),
    "CONST_PI": ("Float64", 0x400921FB54442D18),
    "CONST_ZERO": ("Float64", 0),
    "CONST_NEG_ZERO": ("Float64", 0x8000000000000000),
    "CONST_MIN_SUB": ("Float64", 1),
    "CONST_FLOAT_SMALL": ("Float32", 0x33D6BF95),
    "CONST_FLOAT_NEG_ZERO": ("Float32", 0x80000000),
    "CONST_FLOAT_MIN_SUB": ("Float32", 1),
}


def check_case(cli: Path, directory: Path, language: str, flags: list[str]) -> None:
    generated = directory / "bindings.cj"
    result = run([
        str(cli), str(HEADER), "-o", str(generated), "--no-detect-include-path",
        "--no-layout-test", *flags, "--", "-x", language,
        "-std=c11" if language == "c" else "-std=c++17",
        "--target=x86_64-unknown-linux-gnu",
    ], directory, "generate")
    source = generated.read_text(encoding="utf-8")
    for name in SKIPPED:
        if re.search(rf"\bpublic\s+(?:const|let)\s+{name}\s*:", source):
            raise RuntimeError(f"unsafe constant {name} was emitted")
        if name not in result.stderr:
            raise RuntimeError(f"missing diagnostic for {name}")

    values = dict(FLOAT_VALUES)
    if "--macro-const-use-ctypes" in flags:
        values["MACRO_FLOAT_SMALL"] = ("Float32", 0x33D6BF95)
        values["MACRO_FLOAT_MIN_SUB"] = ("Float32", 1)
    else:
        # The default macro policy still promotes C float values to Float64.
        values["MACRO_FLOAT_SMALL"] = ("Float64", 0x3E7AD7F2A0000000)
        values["MACRO_FLOAT_MIN_SUB"] = ("Float64", 0x36A0000000000000)

    checks = ["package cjbind_ffi", "main(): Int64 {"]
    for name, (ty, bits) in values.items():
        require_declaration(source, name, ty)
        suffix = "u32" if ty == "Float32" else "u64"
        checks += [f"    let checked_{name}: {ty} = {name}",
                   f'    if (checked_{name}.toBits() != {bits}{suffix}) {{ throw Exception("{name} bits") }}']
    require_declaration(source, "CONST_INTEGER", "Int32")
    checks.append('    if (CONST_INTEGER != 42) { throw Exception("CONST_INTEGER") }')
    require_declaration(source, "CONST_ALIAS", "ImmutableValue")
    checks.append('    if (CONST_ALIAS != 43) { throw Exception("CONST_ALIAS") }')
    for name in ("CONST_BYTES", "CONST_ARRAY_ALIAS", "CONST_POINTER"):
        checks.append(f"    let checked_{name}: VArray<UInt8, $3> = {name}")
        for index, byte in enumerate(b"ok\0"):
            checks.append(
                f'    if (checked_{name}[{index}] != {byte}u8) {{ throw Exception("{name}[{index}]") }}')
    checks += ["    return 0", "}"]
    runner = directory / "main.cj"
    runner.write_text("\n".join(checks), encoding="utf-8")
    executable = directory / ("check.exe" if os.name == "nt" else "check")
    run(["cjc", str(generated), str(runner), "--static", "-Woff", "unused", "-o", str(executable)],
        directory, "compile")
    run([str(executable)], directory, "runtime")
    print(f"{directory.name}: {len(values)} float bit patterns, immutable values and rejection diagnostics passed",
          flush=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cli", type=Path, help="use this CLI and skip building")
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--keep-temps", action="store_true")
    args = parser.parse_args()
    cli = args.cli.resolve() if args.cli else ROOT / "target/release/bin" / (
        "cjbind_cli.exe" if os.name == "nt" else "cjbind_cli")
    if args.cli is None and not args.skip_build:
        cli = build_cli()
    if not cli.is_file():
        raise RuntimeError(f"CLI does not exist: {cli}")
    directory = Path(tempfile.mkdtemp(prefix="cjbind-constants-")).resolve()
    failed = False
    try:
        for language in ("c", "c++"):
            for mode, flags in MODES:
                case = directory / f"{language}-{mode}"
                case.mkdir()
                check_case(cli, case, language, flags)
    except Exception:
        failed = True
        print(f"Constant regression files kept at {directory}", file=sys.stderr)
        raise
    finally:
        if not args.keep_temps and not failed:
            if not directory.is_absolute() or directory.resolve() != directory:
                raise RuntimeError(f"refusing to clean unexpected temp path: {directory}")
            shutil.rmtree(directory)
    print("Constant regressions: all eight compile/runtime cases passed", flush=True)


if __name__ == "__main__":
    main()
