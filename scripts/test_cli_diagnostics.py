#!/usr/bin/env python3
"""Verify unmatched allowlist diagnostics from an existing CLI executable."""

from __future__ import annotations

import argparse
import os
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "scripts/testdata/allowlist-diagnostics.hpp"
FASTCALL_FIXTURE = ROOT / "scripts/testdata/mangling-win32.hpp"
MSVC_SYMBOL_FIXTURE = ROOT / "scripts/testdata/method-mangling.hpp"
GENERIC_ALIAS_FIXTURE = ROOT / "scripts/testdata/unsupported-generic-alias.hpp"
PATTERNS = {
    "--allowlist-type": "MissingType",
    "--allowlist-function": "MissingFunction",
    "--allowlist-var": "MISSING_VAR",
    "--allowlist-item": "MissingItem",
}


def default_cli() -> Path:
    executable = "cjbind_cli.exe" if os.name == "nt" else "cjbind_cli"
    candidates = [
        ROOT / "target/release/bin" / executable,
        ROOT / "target/debug/bin" / executable,
    ]
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    locations = ", ".join(str(candidate) for candidate in candidates)
    raise RuntimeError(
        f"an existing static CLI executable is required; checked: {locations}"
    )


def invoke(cli: Path, *, no_record_matches: bool) -> str:
    with tempfile.TemporaryDirectory(prefix="cjbind-cli-diagnostics-") as temp:
        output = Path(temp) / "bindings.cj"
        command = [
            str(cli),
            str(FIXTURE),
            "-o",
            str(output),
            "--package",
            "cjbind_diagnostics",
            "--no-detect-include-path",
            "--allowlist-type",
            "MatchedType",
        ]
        for flag, pattern in PATTERNS.items():
            command.extend([flag, pattern])
        command.extend(["--allowlist-file", "MissingHeader"])
        if no_record_matches:
            command.append("--no-record-matches")
        command.extend(["--", "-x", "c++", "-std=c++14"])

        result = subprocess.run(
            command,
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )
        diagnostics = result.stdout + result.stderr
        if result.returncode != 0:
            raise AssertionError(
                f"CLI exited with {result.returncode}:\n{diagnostics}"
            )
        return diagnostics


def assert_recorded_diagnostics(diagnostics: str) -> None:
    expected = [
        f"Warning: {flag} pattern '{pattern}' did not match any item"
        for flag, pattern in PATTERNS.items()
    ]
    for message in expected:
        count = diagnostics.count(message)
        if count != 1:
            raise AssertionError(
                f"expected exactly one diagnostic {message!r}, found {count}:\n"
                f"{diagnostics}"
            )

    if "pattern 'MatchedType' did not match any item" in diagnostics:
        raise AssertionError(f"matched type was reported as unmatched:\n{diagnostics}")
    file_message = (
        "Warning: --allowlist-file pattern 'MissingHeader' did not match any item"
    )
    if file_message in diagnostics:
        raise AssertionError(f"allowlist-file was reported as unmatched:\n{diagnostics}")
    if diagnostics.count("did not match any item") != len(expected):
        raise AssertionError(f"unexpected unmatched diagnostics:\n{diagnostics}")


def assert_suppressed_diagnostics(diagnostics: str) -> None:
    if "did not match any item" in diagnostics:
        raise AssertionError(
            f"--no-record-matches did not suppress diagnostics:\n{diagnostics}"
        )


def invoke_unsupported_abi(cli: Path, fixture: Path, target: str) -> str:
    with tempfile.TemporaryDirectory(prefix="cjbind-unsupported-abi-") as temp:
        output = Path(temp) / "bindings.cj"
        result = subprocess.run(
            [
                str(cli),
                str(fixture),
                "-o",
                str(output),
                "--package",
                "cjbind_unsupported_abi",
                "--no-detect-include-path",
                "--",
                "-x",
                "c++",
                "-std=c++14",
                f"--target={target}",
            ],
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )
        diagnostics = result.stdout + result.stderr
        if result.returncode != 0:
            raise AssertionError(
                f"CLI exited with {result.returncode}:\n{diagnostics}"
            )
        return diagnostics


def assert_diagnostic(diagnostics: str, expected: str) -> None:
    if expected not in diagnostics:
        raise AssertionError(
            f"missing unsupported ABI diagnostic {expected!r}:\n{diagnostics}"
        )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--cli",
        type=Path,
        help="path to an existing cjbind_cli executable",
    )
    args = parser.parse_args()

    cli = args.cli.resolve() if args.cli is not None else default_cli()
    if not cli.is_file():
        raise RuntimeError(f"CLI executable does not exist: {cli}")
    if not FIXTURE.is_file():
        raise RuntimeError(f"diagnostic fixture does not exist: {FIXTURE}")
    for fixture in [FASTCALL_FIXTURE, MSVC_SYMBOL_FIXTURE, GENERIC_ALIAS_FIXTURE]:
        if not fixture.is_file():
            raise RuntimeError(f"diagnostic fixture does not exist: {fixture}")

    assert_recorded_diagnostics(invoke(cli, no_record_matches=False))
    assert_suppressed_diagnostics(invoke(cli, no_record_matches=True))
    assert_diagnostic(
        invoke_unsupported_abi(cli, FASTCALL_FIXTURE, "i686-pc-win32"),
        "calling convention 'fastcall' cannot be represented by the current Cangjie FFI",
    )
    assert_diagnostic(
        invoke_unsupported_abi(cli, MSVC_SYMBOL_FIXTURE, "x86_64-pc-windows-msvc"),
        "MSVC-decorated ABI symbols cannot be represented by the current Cangjie FFI",
    )
    assert_diagnostic(
        invoke_unsupported_abi(cli, GENERIC_ALIAS_FIXTURE, "i686-pc-win32"),
        "Error: skipping C++ template alias 'FastCallback' because calling convention 'fastcall' cannot be represented by the current Cangjie FFI",
    )
    print("CLI diagnostic regression test passed")


if __name__ == "__main__":
    main()
