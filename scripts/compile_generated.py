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
    ROOT / "cjbind_test/testdata/headers/bitfield-full-word-width.h",
    ROOT / "cjbind_test/testdata/headers/struct_with_anon_union_of_array_members.h",
    ROOT / "cjbind_test/testdata/headers/union_with_nesting.h",
    ROOT / "cjbind_test/testdata/headers/union_with_zero_sized_array.h",
    ROOT / "cjbind_test/testdata/headers/tomlc17-issue19.h",
    ROOT / "cjbind_test/testdata/headers/cxx-access-char16.hxx",
    ROOT / "cjbind_test/testdata/headers/cxx-alignas.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-auto-cstring.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-class-methods.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-nested-classes.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-nontype-aliases.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-partial-specialization.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-reopened-namespaces.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-runtime-lifecycle.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-special-members.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-template-inheritance.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-virtual-signatures.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-inheritance-virtual.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-template.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-derive-codegen.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-derive-compile-smoke.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-derive-function-pointer.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-derive-blob-float.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-derive-blocklisted-manual.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-derive-blocklisted-yes.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-derive-template-instance.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-param-usage-2.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-param-usage-3.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-param-usage-7.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-param-usage-9.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-param-usage-10.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-param-usage-15.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-array.hpp",
    ROOT / "cjbind_test/testdata/headers/cxx-analysis-template-opacity.hpp",
]

HEADER_OPTIONS = {
    "cxx-derive-compile-smoke.hpp": [
        "--with-derive-default",
        "--with-derive-hash",
        "--with-derive-eq",
        "--with-derive-ord",
    ],
    "cxx-analysis-derive-codegen.hpp": [
        "--with-derive-default",
        "--with-derive-hash",
        "--with-derive-eq",
        "--with-derive-ord",
        "--impl-debug",
        "--impl-partialeq",
        "--disable-untagged-union",
        "--opaque-type",
        "^OpaqueWord$",
        "--no-hash",
        "^NoHash$",
        "--no-partialeq",
        "^NoPartialEq$",
    ],
    "cxx-derive-function-pointer.hpp": [
        "--with-derive-default",
        "--with-derive-hash",
        "--with-derive-eq",
        "--with-derive-ord",
    ],
    "cxx-derive-blob-float.hpp": [
        "--with-derive-default",
        "--with-derive-hash",
        "--with-derive-eq",
        "--with-derive-ord",
    ],
    "cxx-derive-template-instance.hpp": [
        "--with-derive-default",
        "--with-derive-hash",
        "--with-derive-eq",
        "--with-derive-ord",
        "--opaque-type",
        "^ConflictTemplate<int>$",
    ],
}

HEADER_CLANG_ARGS = {
    "cxx-derive-blob-float.hpp": ["--target=i686-unknown-linux-gnu"],
}

EXPECTED_GENERATED = {
    "cxx-derive-blocklisted-manual.hpp":
        ROOT / "cjbind_test/testdata/expected/cxx-derive-blocklisted-manual.cj",
    "cxx-derive-blocklisted-yes.hpp":
        ROOT / "cjbind_test/testdata/expected/cxx-derive-blocklisted-yes.cj",
}

SUPPORT_SOURCES = {
    "cxx-derive-blocklisted-manual.hpp": """package cjbind_ffi

@C
public struct ManualExternal_ManualExternal {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
    public operator func ==(right: ManualExternal_ManualExternal): Bool {
        return this.value == right.value
    }
    public operator func !=(right: ManualExternal_ManualExternal): Bool {
        return !(this == right)
    }
}
""",
    "cxx-derive-blocklisted-yes.hpp": """package cjbind_ffi

@C
public struct ExternalCapabilities_ExternalCapabilities {
    public let first: Int32
    public let second: Int32
    public let third: Int32
    public init(first: Int32, second: Int32, third: Int32) {
        this.first = first
        this.second = second
        this.third = third
    }
    public func toString(): String {
        return "ExternalCapabilities_ExternalCapabilities(${first}, ${second}, ${third})"
    }
    public func hashCode(): Int64 {
        var hash = this.first.hashCode()
        hash = ((hash << 5) | (hash >> 59)) ^ this.second.hashCode()
        return ((hash << 5) | (hash >> 59)) ^ this.third.hashCode()
    }
    public operator func ==(right: ExternalCapabilities_ExternalCapabilities): Bool {
        return this.first == right.first && this.second == right.second && this.third == right.third
    }
    public operator func !=(right: ExternalCapabilities_ExternalCapabilities): Bool {
        return !(this == right)
    }
    public operator func <(right: ExternalCapabilities_ExternalCapabilities): Bool {
        if (this.first != right.first) {
            return this.first < right.first
        }
        if (this.second != right.second) {
            return this.second < right.second
        }
        return this.third < right.third
    }
    public operator func >(right: ExternalCapabilities_ExternalCapabilities): Bool {
        return right < this
    }
}
""",
}


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


def write_smoke_project(project: Path, generated: str, support: str | None = None) -> None:
    (project / "src").mkdir(parents=True)
    (project / "cangjie-sdk.toml").write_text(
        '[toolchain]\nchannel = "nightly"\n',
        encoding="utf-8",
    )
    (project / "cjpm.toml").write_text(
        """[package]
  cjc-version = "1.1.3"
  compile-option = "-Woff unused"
  name = "cjbind_ffi"
  output-type = "static"
  version = "0.0.0"
""",
        encoding="utf-8",
    )
    (project / "src/wrap.cj").write_text(generated, encoding="utf-8")
    if support is not None:
        (project / "src/support.cj").write_text(support, encoding="utf-8")


def compile_header(cli: Path, header: Path, keep_temps: bool) -> None:
    temp_root = Path(tempfile.mkdtemp(prefix=f"cjbind-smoke-{header.stem}-"))
    failed = False
    try:
        out = temp_root / "generated.cj"
        expected = EXPECTED_GENERATED.get(header.name)
        if expected is None:
            command = [
                str(cli),
                str(header),
                "-o",
                str(out),
                "--package",
                "cjbind_ffi",
                "--no-detect-include-path",
            ]
            command.extend(HEADER_OPTIONS.get(header.name, []))
            command.append("--")
            command.extend(HEADER_CLANG_ARGS.get(
                header.name,
                ["--target=x86_64-unknown-linux-gnu"],
            ))
            run(command, cwd=ROOT)
            generated = out.read_text(encoding="utf-8")
        else:
            generated = expected.read_text(encoding="utf-8")

        project = temp_root / "project"
        write_smoke_project(
            project,
            generated,
            SUPPORT_SOURCES.get(header.name),
        )
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
