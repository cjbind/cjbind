package cjbind

import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.unittest.*
import std.unittest.testmacro.*

import cjbind.options.CjbindOptions

func generateBitfieldLayoutFixture(header: String, target: String): String {
    let directory = Directory.createTemp(getTempDirectory())
    try {
        let input = directory.join("bitfield_layout.h")
        File.writeTo(input, header.toArray())
        let options = CjbindOptions()
        options.headers.add(input.toString())
        options.noDetectIncludePath = true
        options.clangArgs.add(all: ["-x", "c", "-std=gnu11", "--target=${target}"])
        return generate(options)
    } finally {
        remove(directory, recursive: true)
    }
}

@Test
public class BitfieldAbiGenerationTest {
    @TestCase
    func followsAbsoluteClangOffsetsAcrossDifferentAllocationUnits(): Unit {
        let binding = generateBitfieldLayoutFixture("""
typedef unsigned int U32;
typedef long long I64;
struct CrossUnits {
    U32 first : 3;
    I64 second : 5;
    int third : 4;
};
""", "x86_64-w64-mingw32")

        @Expect(binding.contains("VArray<UInt64, $3>"), true)
        @Expect(binding.contains("CPointer<UInt8>(inout s), 64, 5"), true)
        @Expect(binding.contains("CPointer<UInt8>(inout s), 128, 4"), true)
        @Expect(binding.contains("VArray<UInt64, $0>"), true)
    }

    @TestCase
    func preservesSysvUnalignedBitfieldBytesAndRecordAlignment(): Unit {
        let header = """
struct LeadingByte {
    unsigned char prefix;
    unsigned char _bitfield_1;
    unsigned int first : 1;
    unsigned int second : 1;
    unsigned char suffix;
    unsigned char _cjbind_bitfield_alignment_marker;
};
"""
        let sysv = generateBitfieldLayoutFixture(header, "x86_64-unknown-linux-gnu")
        let windows = generateBitfieldLayoutFixture(header, "x86_64-w64-mingw32")

        @Expect(sysv.contains("var _bitfield_1 : UInt8"), true)
        @Expect(sysv.contains("VArray<UInt32, $0>"), true)
        @Expect(sysv.contains("_cjbind_bitfield_alignment_marker1"), true)
        @Expect(sysv.contains("var _bitfield_11"), true)
        @Expect(windows.contains("VArray<UInt16, $3>"), true)
        @Expect(windows.contains("CPointer<UInt8>(inout s), 16, 1"), true)
        @Expect(windows.contains("VArray<UInt32, $0>"), true)
        @Expect(windows.contains("_cjbind_bitfield_alignment_marker1"), true)
        @Expect(windows.contains("var _bitfield_11"), true)
    }

    @TestCase
    func keepsZeroWidthBoundariesAndMultipleRunsAtClangOffsets(): Unit {
        let header = """
struct Runs {
    unsigned char prefix;
    unsigned int first : 3;
    unsigned int : 0;
    unsigned int second : 2;
    unsigned char middle;
    unsigned short tail : 4;
};

struct ZeroGap {
    char c;
    unsigned int : 0;
    unsigned int b : 1;
    char d;
};
"""
        let sysv = generateBitfieldLayoutFixture(header, "x86_64-unknown-linux-gnu")
        let windows = generateBitfieldLayoutFixture(header, "x86_64-w64-mingw32")

        @Expect(sysv.contains("VArray<UInt8, $4>"), true)
        @Expect(sysv.contains("CPointer<UInt8>(inout s), 24, 2"), true)
        @Expect(sysv.contains("var _bitfield_2 : UInt16"), true)
        @Expect(sysv.contains("CPointer<UInt8>(inout s), 24, 1"), true)
        @Expect(windows.contains("VArray<UInt8, $11>"), true)
        @Expect(windows.contains("CPointer<UInt8>(inout s), 56, 2"), true)
        @Expect(windows.contains("VArray<UInt8, $3>"), true)
        @Expect(windows.contains("VArray<UInt8, $7>"), true)
        @Expect(windows.contains("CPointer<UInt8>(inout s), 24, 1"), true)
    }
}
