#!/usr/bin/env python3
"""Compile and execute string constants generated in both output modes."""

from __future__ import annotations

import argparse
import os
import subprocess
import tempfile
from pathlib import Path

from compile_generated import ROOT, build_cli


# Explicit byte expectations check that escaping preserves the C value.
CASES = [
    ("EMPTY", r'""', b""),
    ("SIMPLE", r'"hello"', b"hello"),
    ("QUOTES", r'"quote\" and \'"', b"quote\" and '"),
    ("BACKSLASH", r'"C:\\new\\file"', b"C:\\new\\file"),
    ("LINES", r'"first\nsecond\rthird\tend"', b"first\nsecond\rthird\tend"),
    ("CONTROLS", r'"\a\b\f\v\x1f\x7f"', bytes([7, 8, 12, 11, 31, 127])),
    ("INTERPOLATION", r'"${1+2} $name"', b"${1+2} $name"),
    ("CONCATENATED", r'"first" " second"', b"first second"),
    ("EMBEDDED_NUL", r'"a\0b"', b"a\0b"),
    ("LEADING_NUL", r'"\0first"', b"\0first"),
    ("TRAILING_NUL", r'"last\0"', b"last\0"),
    ("CONCATENATED_NUL", r'"a\0" "b"', b"a\0b"),
    ("PADDED_NUL", r'"a\0b"', b"a\0b"),
    ("UNICODE", r'"\xe4\xbb\x93\xe9\xa2\x89\xf0\x9f\x98\x80"', "仓颉😀".encode()),
    ("NON_UTF8", r'"\xff\xfe"', bytes([255, 254])),
]


def run(command: list[str]) -> None:
    print("+ " + " ".join(command), flush=True)
    subprocess.run(command, cwd=ROOT, check=True)


def check_mode(cli: Path, directory: Path, *, strings: bool, comments: bool) -> None:
    header = directory / "strings.h"
    declarations = "\n".join(
        f"static const char {name}[{'20' if name == 'PADDED_NUL' else ''}] = {literal};"
        for name, literal, _ in CASES
    )
    macros = "\n".join(f"#define MACRO_{name} {literal}" for name, literal, _ in CASES)
    pointers = "\n".join(f"static const char *const POINTER_{name} = ({literal});" for name, literal, _ in CASES)
    header.write_text(declarations + "\n" + pointers + "\n" + macros + "\n", encoding="utf-8")
    generated = directory / "bindings.cj"
    command = [str(cli), str(header), "-o", str(generated), "--no-detect-include-path"]
    if strings:
        command.append("--make-cjstring")
    if not comments:
        command.append("--no-comment")
    run(command)

    checks = ["package cjbind_ffi", "main(): Int64 {"]
    values = CASES + [
        (f"{prefix}_{name}", literal, value)
        for prefix in ("MACRO", "POINTER")
        for name, literal, value in CASES
    ]
    for name, _, value in values:
        is_string = strings and not name.endswith("NON_UTF8")
        expected = value if is_string else value + b"\0"
        if is_string:
            checks.append(f'    if ({name}.size != {len(expected)}) {{ throw Exception("{name} length") }}')
        else:
            # This also verifies the trailing NUL and the generated array's size.
            checks.append(f"    let checked_{name}: VArray<UInt8, ${len(expected)}> = {name}")
        for index, byte in enumerate(expected):
            checks.append(f'    if ({name}[{index}] != {byte}u8) {{ throw Exception("{name}[{index}]") }}')
    checks.extend(["    return 0", "}"])
    runner = directory / "main.cj"
    runner.write_text("\n".join(checks), encoding="utf-8")
    executable = directory / ("check.exe" if os.name == "nt" else "check")
    run(["cjc", str(generated), str(runner), "--static", "-Woff", "unused", "-o", str(executable)])
    run([str(executable)])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skip-build", action="store_true")
    args = parser.parse_args()
    cli = ROOT / "target/release/bin" / ("cjbind_cli.exe" if os.name == "nt" else "cjbind_cli")
    if not args.skip_build:
        cli = build_cli()
    with tempfile.TemporaryDirectory(prefix="cjbind-string-codegen-") as temp:
        for strings in (True, False):
            for comments in (False, True):
                directory = Path(temp) / f"strings-{strings}-comments-{comments}"
                directory.mkdir()
                check_mode(cli, directory, strings=strings, comments=comments)
    print("String codegen: all four compile and runtime checks passed")


if __name__ == "__main__":
    main()
