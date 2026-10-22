#!/usr/bin/env python3
"""Compile and execute precisely typed macros for three C target data models."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

from compile_generated import ROOT, build_cli


HEADER = ROOT / "cjbind_test/testdata/headers/support/ir/macro-const-types.h"
TARGETS = [
    ("x86_64-unknown-linux-gnu", "Int64", "UInt64", "Int32", -1),
    ("x86_64-pc-windows-msvc", "Int32", "UInt32", "UInt16", 65535),
    ("i686-unknown-linux-gnu", "Int32", "UInt32", "Int32", -1),
]

# These are independent IEEE bit-pattern expectations, not generated literals.
FLOAT_BITS = {
    "FLOAT_ZERO": ("Float32", 0),
    "FLOAT_NEG_ZERO": ("Float32", 0x80000000),
    "FLOAT_MAX": ("Float32", 0x7F7FFFFF),
    "FLOAT_MIN_SUB": ("Float32", 1),
    "FLOAT_THIRD": ("Float32", 0x3EAAAAAB),
    "DOUBLE_ZERO": ("Float64", 0),
    "DOUBLE_NEG_ZERO": ("Float64", 0x8000000000000000),
    "DOUBLE_MIN_SUB": ("Float64", 1),
    "DOUBLE_THIRD": ("Float64", 0x3FD5555555555555),
}
HALF_BITS = {"HALF_ONE": 0x3E00, "HALF_MIN_SUB": 1, "HALF_NEG_ZERO": 0x8000}


def run(command: list[str], directory: Path, log_name: str) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                            encoding="utf-8", errors="replace", timeout=120)
    (directory / f"{log_name}.stdout").write_text(result.stdout, encoding="utf-8")
    (directory / f"{log_name}.stderr").write_text(result.stderr, encoding="utf-8")
    if result.returncode:
        raise RuntimeError(f"{' '.join(command)} failed ({result.returncode}):\n{result.stderr}")
    return result


def generate(cli: Path, directory: Path, target: str, language: str,
             flags: list[str], name: str, unsigned_char: bool = False) -> tuple[Path, str]:
    output = directory / f"{name}.cj"
    result = run([
        str(cli), str(HEADER), "-o", str(output), "--no-detect-include-path",
        "--no-layout-test", *flags, "--", "-x", language,
        "-std=c11" if language == "c" else "-std=c++17", f"--target={target}",
        "-funsigned-char" if unsigned_char else "-fsigned-char",
    ], directory, name)
    return output, result.stderr


def require_declaration(source: str, name: str, ty: str) -> None:
    if re.search(rf"\bpublic\s+(?:const|let)\s+{name}\s*:\s*{ty}\s*=", source) is None:
        raise RuntimeError(f"missing {name}: {ty}")


def check_case(cli: Path, directory: Path, target: str, long_type: str,
               ulong_type: str, wchar_type: str, wchar_value: int,
               language: str, *, unsigned_char: bool = False) -> None:
    generated, diagnostics = generate(cli, directory, target, language,
                                     ["--macro-const-use-ctypes"], "precise", unsigned_char)
    combined, _ = generate(cli, directory, target, language,
                           ["--macro-const-use-ctypes", "--fit-macro-constants"],
                           "combined", unsigned_char)
    source = generated.read_text(encoding="utf-8")
    if source != combined.read_text(encoding="utf-8"):
        raise RuntimeError("--fit-macro-constants changed precise C macro types")

    char_type = "UInt8" if unsigned_char else "Int8"
    integers = {
        "INT_ZERO": ("Int32", 0), "INT_NEG": ("Int32", -1),
        "INT_MAX": ("Int32", 2147483647), "UINT_MAX": ("UInt32", 4294967295),
        "HEX_HIGH": ("UInt32", 2147483648), "ULONG_ZERO": (ulong_type, 0),
        "LONG_NEG": (long_type, -2147483648), "TYPEDEF_LONG": (long_type, 1),
        "ULL_MAX": ("UInt64", 18446744073709551615),
        "LL_MIN": ("Int64", -9223372036854775808),
        "SHORT_NEG": ("Int16", -32768), "USHORT_MAX": ("UInt16", 65535),
        "SCHAR_NEG": ("Int8", -128), "UCHAR_MAX": ("UInt8", 255),
        "CHAR_NEG": (char_type, 255 if unsigned_char else -1),
        "CHAR_ZERO": (char_type, 0),
        "C_CHAR": ("Int32" if language == "c" else char_type, 65),
        "PROMOTED_CHAR": ("Int32", 3),
    }
    if language == "c++":
        integers.update({
            "WCHAR_NEG": (wchar_type, wchar_value), "WCHAR_VALUE": (wchar_type, 937),
            "CHAR16_HIGH": ("UInt16", 65535), "CHAR32_HIGH": ("UInt32", 4294967295),
            "CHAR16_VALUE": ("UInt16", 937), "CHAR32_VALUE": ("UInt32", 128512),
        })
    else:
        integers["ENUM_NEG"] = ("Int32", -2)

    checks = ["package cjbind_ffi", "main(): Int64 {"]
    for name, (ty, value) in integers.items():
        require_declaration(source, name, ty)
        # Assignment checks the type independently of parsing the source text.
        checks += [f"    let checked_{name}: {ty} = {name}",
                   f'    if (checked_{name} != {value}) {{ throw Exception("{name}") }}']
    for name, value in (("BOOL_TRUE", "true"), ("BOOL_FALSE", "false")):
        require_declaration(source, name, "Bool")
        checks += [f"    let checked_{name}: Bool = {name}",
                   f'    if (checked_{name} != {value}) {{ throw Exception("{name}") }}']
    for name, (ty, bits) in FLOAT_BITS.items():
        require_declaration(source, name, ty)
        suffix = "u32" if ty == "Float32" else "u64"
        checks += [f"    let checked_{name}: {ty} = {name}",
                   f'    if (checked_{name}.toBits() != {bits}{suffix}) {{ throw Exception("{name} bits") }}']
    for name, bits in HALF_BITS.items():
        require_declaration(source, name, "__CjbindFloat16")
        checks += [f"    let checked_{name}: __CjbindFloat16 = {name}",
                   f'    if (checked_{name}.bits != {bits}u16) {{ throw Exception("{name} bits") }}']

    skipped = ["ENUM_CAST", "FLOAT_INFINITY", "DOUBLE_NAN"]
    if language == "c++":
        skipped += ["ENUM_NEG", "SCOPED_ENUM"]
    if target == "x86_64-pc-windows-msvc":
        require_declaration(source, "LONG_DOUBLE", "Float64")
        checks += ["    let checked_LONG_DOUBLE: Float64 = LONG_DOUBLE",
                   '    if (checked_LONG_DOUBLE != 1.0) { throw Exception("LONG_DOUBLE") }']
    else:
        skipped.append("LONG_DOUBLE")
    if target.startswith("x86_64"):
        skipped.append("WIDE_INT")
    for name in skipped:
        if re.search(rf"\bpublic\s+(?:const|let)\s+{name}\s*:", source):
            raise RuntimeError(f"unsupported macro {name} was emitted with a lossy type")
        if name not in diagnostics:
            raise RuntimeError(f"missing diagnostic for unsupported macro {name}")

    checks += ["    return 0", "}"]
    runner = directory / "main.cj"
    runner.write_text("\n".join(checks), encoding="utf-8")
    executable = directory / ("check.exe" if os.name == "nt" else "check")
    run(["cjc", str(generated), str(runner), "--static", "-Woff", "unused", "-o", str(executable)],
        directory, "compile")
    run([str(executable)], directory, "runtime")
    print(f"{target}, {language}, {'unsigned' if unsigned_char else 'signed'} char: "
          f"{len(integers) + 2 + len(FLOAT_BITS) + len(HALF_BITS)} typed values and flag precedence passed",
          flush=True)


def check_defaults(cli: Path, directory: Path) -> None:
    for name, flags, signed, unsigned in [
        ("default", [], "Int64", "UInt64"),
        ("fit", ["--fit-macro-constants"], "Int8", "UInt8"),
    ]:
        generated, _ = generate(cli, directory, TARGETS[0][0], "c++", flags, name)
        source = generated.read_text(encoding="utf-8")
        require_declaration(source, "INT_ZERO", signed)
        require_declaration(source, "ULONG_ZERO", unsigned)
        require_declaration(source, "ULL_MAX", "UInt64")
    print("Default macro typing and --fit-macro-constants are unchanged", flush=True)


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
    directory = Path(tempfile.mkdtemp(prefix="cjbind-macro-types-")).resolve()
    failed = False
    try:
        for target in TARGETS:
            for language in ("c", "c++"):
                case = directory / f"{target[0]}-{language}"
                case.mkdir()
                check_case(cli, case, *target, language)
        case = directory / "unsigned-char"
        case.mkdir()
        check_case(cli, case, *TARGETS[0], "c++", unsigned_char=True)
        check_defaults(cli, directory)
    except Exception:
        failed = True
        print(f"Macro type test files kept at {directory}", file=sys.stderr)
        raise
    finally:
        if not args.keep_temps and not failed:
            if not directory.is_absolute() or directory.resolve() != directory:
                raise RuntimeError(f"refusing to clean unexpected temp path: {directory}")
            shutil.rmtree(directory)
    print("Precise macro types: all seven compile/runtime cases passed", flush=True)


if __name__ == "__main__":
    main()
