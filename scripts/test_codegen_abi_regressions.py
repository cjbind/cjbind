#!/usr/bin/env python3
"""Compile and execute bindings whose names previously changed their C ABI."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]

HEADER = r"""
typedef int BOOL;
typedef float CGFloat;
typedef short NSInteger;
typedef unsigned short NSUInteger;
typedef float NSTimeInterval;

struct Flags { BOOL values[4]; int tail; };
struct Collision { int type; int type_; int type__1; };
union UnionCollision { int type; int type_; int _storage; };
struct BitCollision {
    unsigned int type : 3;
    unsigned int type_ : 3;
    unsigned int type__1 : 3;
    int _bitfield_0;
};

BOOL bump_bool(BOOL value);
CGFloat bump_float(CGFloat value);
unsigned long long flags_size(void);
int flags_tail(struct Flags *value);
int collision_sum(struct Collision *value);
int union_value(union UnionCollision *value);
int bit_collision_sum(struct BitCollision *value);
int match(int match);
int ifNone(int ifNone);
int type(int type);
static int get(int get) { return get + 3; }
"""

C_SOURCE = r"""
#include "bindings.h"
BOOL bump_bool(BOOL value) { return value + 256; }
CGFloat bump_float(CGFloat value) { return value + 0.5f; }
unsigned long long flags_size(void) { return sizeof(struct Flags); }
int flags_tail(struct Flags *value) { return value->tail; }
int collision_sum(struct Collision *value) {
    return value->type + value->type_ + value->type__1;
}
int union_value(union UnionCollision *value) { return value->_storage; }
int bit_collision_sum(struct BitCollision *value) {
    return value->type + value->type_ + value->type__1 + value->_bitfield_0;
}
int match(int match) { return match + 1; }
int ifNone(int ifNone) { return ifNone + 2; }
int type(int type) { return type + 4; }
"""

MAIN = r"""
package cjbind_ffi

func require(value: Bool, message: String): Unit {
    if (!value) { throw Exception(message) }
}

main() {
    require(sizeOf<BOOL>() == 4, "BOOL must retain its C int representation")
    require(sizeOf<CGFloat>() == 4, "CGFloat must retain its C float representation")
    require(sizeOf<NSInteger>() == 2, "NSInteger must retain its underlying type")
    require(sizeOf<NSUInteger>() == 2, "NSUInteger must retain its underlying type")
    require(sizeOf<NSTimeInterval>() == 4, "NSTimeInterval must retain its underlying type")
    var flags = Flags([1, 2, 3, 4], 42)
    var collision = Collision(10, 20, 30)
    require(collision.type_ == 10 && collision.type__2 == 20 && collision.type__1 == 30,
        "renamed ordinary fields must retain their order")
    var unionCollision = UnionCollision()
    unionCollision.type_ = 40
    require(unionCollision.type__1 == 40, "union keyword fields must share storage")
    unionCollision._storage_1 = 55
    var bitCollision = BitCollision()
    bitCollision.type_ = 1
    bitCollision.type__2 = 2
    bitCollision.type__1 = 3
    bitCollision._bitfield_0 = 40
    unsafe {
        require(bump_bool(256) == 512, "BOOL function values must not be truncated")
        require(bump_float(1.5) == 2.0, "CGFloat function values must use the float ABI")
        require(UInt64(sizeOf<Flags>()) == flags_size(), "record size must match C")
        require(flags_tail(CPointer<Flags>(inout flags)) == 42, "record field offset must match C")
        require(collision_sum(CPointer<Collision>(inout collision)) == 60, "ordinary fields must match C")
        require(union_value(CPointer<UnionCollision>(inout unionCollision)) == 55, "union fields must match C")
        require(bit_collision_sum(CPointer<BitCollision>(inout bitCollision)) == 46, "bitfields must match C")
        require(match_cjbindwrapper(10) == 11, "keyword C symbol must be preserved")
        require(ifNone_cjbindwrapper(10) == 12, "builtin C symbol must be preserved")
        require(type_cjbindwrapper(10) == 14, "keyword C calls must keep parameter names distinct")
        require(get_(10) == 13, "static bridge symbols must be preserved")
    }
    println("codegen ABI regressions passed")
}
"""


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
    compiler = os.environ.get("CC") or shutil.which("clang") or shutil.which("gcc")
    if not compiler:
        raise RuntimeError("a C compiler is required (set CC to its executable)")

    temp_root = Path(tempfile.mkdtemp(prefix="cjbind-codegen-abi-"))
    failed = False
    try:
        header = temp_root / "bindings.h"
        header.write_text(HEADER, encoding="utf-8")
        source = temp_root / "bindings.c"
        source.write_text(C_SOURCE, encoding="utf-8")
        generated = temp_root / "bindings.cj"
        bridge = temp_root / "bridge.c"
        run([
            str(binary), "--no-detect-include-path", "--make-func-wrapper",
            "--wrap-static-fns", "--wrap-static-fns-path", str(bridge),
            "-o", str(generated), str(header), "--", "-x", "c",
        ], cwd=ROOT)
        runtime = temp_root / "main.cj"
        runtime.write_text(MAIN, encoding="utf-8")
        objects = [temp_root / "bindings.o", temp_root / "bridge.o"]
        for c_file, obj in zip((source, bridge), objects):
            run([compiler, "-c", str(c_file), "-o", str(obj)], cwd=temp_root)
        executable = temp_root / ("abi-test.exe" if os.name == "nt" else "abi-test")
        compiler_args = [
            "cjc", str(generated), str(runtime), "-g", "--static", "-Woff", "unused",
            *(f"--link-option={obj}" for obj in objects), "-o", str(executable),
        ]
        run(compiler_args, cwd=ROOT)
        run([str(executable)], cwd=temp_root)

        # Deliberately corrupt the expected size, leaving the generated check
        # intact: merely matching its source text does not prove it executes.
        code = generated.read_text(encoding="utf-8")
        expected = "if (size != 20)"
        if code.count(expected) != 1:
            raise AssertionError("expected one generated size check for Flags")
        generated.write_text(code.replace(expected, "if (size != 21)", 1), encoding="utf-8")
        run(compiler_args, cwd=ROOT)
        rejected = subprocess.run([str(executable)], cwd=temp_root, capture_output=True, text=True)
        if rejected.returncode == 0 or "Size of Flags" not in rejected.stdout + rejected.stderr:
            raise AssertionError("a mismatched generated debug layout check must fail at startup")
        print("Generated debug layout check rejected the mismatched size.")
    except (subprocess.CalledProcessError, OSError, AssertionError):
        failed = True
        print(f"Codegen ABI test files kept at {temp_root}", file=sys.stderr)
        raise
    finally:
        if not args.keep_temps and not failed:
            shutil.rmtree(temp_root, ignore_errors=True)


if __name__ == "__main__":
    main()
