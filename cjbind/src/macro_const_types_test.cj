package cjbind

import cjbind.options.CjbindOptions
import std.unittest.*
import std.unittest.testmacro.*

func generateMacroTypeFixture(target: String, precise: Bool, fit: Bool, unsignedChar!: Bool = false): String {
    let options = CjbindOptions()
    options.headers.add("cjbind_test/testdata/headers/support/ir/macro-const-types.h")
    options.noDetectIncludePath = true
    options.noLayoutTests = true
    options.macroConstUseCTypes = precise
    options.fitMacroConstants = fit
    options.clangArgs.add(
        all: [
            "-x",
            "c++",
            "-std=c++17",
            "--target=${target}",
            if (unsignedChar) {
                "-funsigned-char"
            } else {
                "-fsigned-char"
            }
        ]
    )
    return generate(options)
}

@Test
public class MacroConstTypesTest {
    @TestCase
    func retainsExpressionTypesAndTargetWidths(): Unit {
        for ((target, longType, ulongType, wcharType, wcharValue) in [
            ("x86_64-unknown-linux-gnu", "Int64", "UInt64", "Int32", "-1"),
            ("x86_64-pc-windows-msvc", "Int32", "UInt32", "UInt16", "65535"),
            ("i686-unknown-linux-gnu", "Int32", "UInt32", "Int32", "-1")
        ]) {
            let binding = generateMacroTypeFixture(target, true, false)
            for ((name, ty, value) in [
                ("INT_ZERO", "Int32", "0"),
                ("INT_NEG", "Int32", "-1"),
                ("HEX_HIGH", "UInt32", "2147483648"),
                ("ULONG_ZERO", ulongType, "0"),
                ("LONG_NEG", longType, "-2147483648"),
                ("TYPEDEF_LONG", longType, "1"),
                ("ULL_MAX", "UInt64", "18446744073709551615"),
                ("LL_MIN", "Int64", "-9223372036854775808"),
                ("SHORT_NEG", "Int16", "-32768"),
                ("USHORT_MAX", "UInt16", "65535"),
                ("SCHAR_NEG", "Int8", "-128"),
                ("UCHAR_MAX", "UInt8", "255"),
                ("CHAR_NEG", "Int8", "-1"),
                ("CHAR_ZERO", "Int8", "0"),
                ("C_CHAR", "Int8", "65"),
                ("PROMOTED_CHAR", "Int32", "3"),
                ("BOOL_TRUE", "Bool", "true"),
                ("BOOL_FALSE", "Bool", "false"),
                ("WCHAR_NEG", wcharType, wcharValue),
                ("CHAR16_HIGH", "UInt16", "65535"),
                ("CHAR32_HIGH", "UInt32", "4294967295")
            ]) {
                @Expect(binding.contains("public const ${name} : ${ty} = ${value}"), true)
            }
            @Expect(binding.contains("public const FLOAT_ZERO : Float32 = 0x0.0000000000000p-1022"), true)
            @Expect(binding.contains("public const DOUBLE_ZERO : Float64 = 0x0.0000000000000p-1022"), true)
            @Expect(binding.contains("public const FLOAT_NEG_ZERO : Float32 = -0x0.0000000000000p-1022"), true)
            @Expect(binding.contains("public const DOUBLE_MIN_SUB : Float64 = 0x0.0000000000001p-1022"), true)
            @Expect(binding.contains("public let HALF_ONE : __CjbindFloat16"), true)
            for (name in ["ENUM_NEG", "ENUM_CAST", "SCOPED_ENUM", "WIDE_INT", "FLOAT_INFINITY", "DOUBLE_NAN"]) {
                @Expect(binding.contains("public const ${name} :"), false)
            }
            @Expect(binding.contains("public const LONG_DOUBLE : Float64"), target == "x86_64-pc-windows-msvc")
        }
    }

    @TestCase
    func preservesDefaultsAndTakesPrecedenceOverFitting(): Unit {
        let target = "x86_64-unknown-linux-gnu"
        let normal = generateMacroTypeFixture(target, false, false)
        let fitted = generateMacroTypeFixture(target, false, true)
        let precise = generateMacroTypeFixture(target, true, false)
        let combined = generateMacroTypeFixture(target, true, true)
        @Expect(normal.contains("public const INT_ZERO : Int64 = 0"), true)
        @Expect(normal.contains("public const ULONG_ZERO : UInt64 = 0"), true)
        @Expect(fitted.contains("public const INT_ZERO : Int8 = 0"), true)
        @Expect(fitted.contains("public const ULONG_ZERO : UInt8 = 0"), true)
        @Expect(precise, combined)
    }

    @TestCase
    func usesTheConfiguredPlainCharSignedness(): Unit {
        let binding = generateMacroTypeFixture("x86_64-unknown-linux-gnu", true, false, unsignedChar: true)
        @Expect(binding.contains("public const CHAR_NEG : UInt8 = 255"), true)
        @Expect(binding.contains("public const C_CHAR : UInt8 = 65"), true)
        @Expect(binding.contains("public const SCHAR_NEG : Int8 = -128"), true)
    }
}
