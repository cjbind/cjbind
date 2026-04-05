package cjbind.codegen

import std.unittest.*
import std.unittest.testmacro.*

import cjbind_token.{tokenStreamFromTemplate, TokenStream}
import cjbind.ir.*

// === Attributes.doc ===

@Test
public class AttributesDocTest {
    @TestCase
    func singleLine(): Unit {
        let ts = Attributes.doc(" hello world")
        @Expect(ts.toString(), "// hello world")
    }

    @TestCase
    func multiLine(): Unit {
        let ts = Attributes.doc(" line1\n line2\n line3")
        let result = ts.toString()
        @Expect(result.contains("// line1"), true)
        @Expect(result.contains("// line2"), true)
        @Expect(result.contains("// line3"), true)
    }

    @TestCase
    func emptyComment(): Unit {
        let ts = Attributes.doc("")
        // Empty string has no lines, so doc produces empty stream
        @Expect(ts.toString(), "")
    }

    @TestCase
    func preservesWhitespace(): Unit {
        let ts = Attributes.doc("   indented")
        @Expect(ts.toString(), "//   indented")
    }

    @TestCase
    func trailingNewline(): Unit {
        let ts = Attributes.doc(" a\n b")
        let result = ts.toString()
        // Should have newline between lines but not trailing
        @Expect(result.contains("\n"), true)
    }
}

// === TokenStream.toPtr ===

@Test
public class TokenStreamToPtrTest {
    @TestCase
    func simpleType(): Unit {
        let ts = tokenStreamFromTemplate("Int32")
        @Expect(ts.toPtr().toString(), "CPointer<Int32>")
    }

    @TestCase
    func nestedPtr(): Unit {
        let ts = tokenStreamFromTemplate("CPointer<UInt8>")
        @Expect(ts.toPtr().toString(), "CPointer<CPointer<UInt8>>")
    }

    @TestCase
    func unitType(): Unit {
        let ts = tokenStreamFromTemplate("Unit")
        @Expect(ts.toPtr().toString(), "CPointer<Unit>")
    }
}

// === Helpers.blob ===

@Test
public class HelpersBlobTest {
    @TestCase
    func singleUInt8(): Unit {
        // Layout(1, 1) -> align=1 -> UInt8, size/align=1 -> no array
        let layout = Layout(1, 1)
        let ts = Helpers.blob(unsafe { zeroValue<CjbindContext>() }, layout)
        @Expect(ts.toString(), "UInt8")
    }

    @TestCase
    func singleUInt32(): Unit {
        let layout = Layout(4, 4)
        let ts = Helpers.blob(unsafe { zeroValue<CjbindContext>() }, layout)
        @Expect(ts.toString(), "UInt32")
    }

    @TestCase
    func varrayUInt32(): Unit {
        // Layout(8, 4) -> align=4 -> UInt32, arraySize=8/4=2
        let layout = Layout(8, 4)
        let ts = Helpers.blob(unsafe { zeroValue<CjbindContext>() }, layout)
        let result = ts.toString()
        @Expect(result.contains("VArray"), true)
        @Expect(result.contains("UInt32"), true)
        @Expect(result.contains("2"), true)
    }

    @TestCase
    func varrayUInt64(): Unit {
        // Layout(24, 8) -> align=8 -> UInt64, arraySize=24/8=3
        let layout = Layout(24, 8)
        let ts = Helpers.blob(unsafe { zeroValue<CjbindContext>() }, layout)
        let result = ts.toString()
        @Expect(result.contains("VArray"), true)
        @Expect(result.contains("UInt64"), true)
        @Expect(result.contains("3"), true)
    }

    @TestCase
    func singleUInt16(): Unit {
        let layout = Layout(2, 2)
        let ts = Helpers.blob(unsafe { zeroValue<CjbindContext>() }, layout)
        @Expect(ts.toString(), "UInt16")
    }

    @TestCase
    func unknownAlignFallsBackToUInt8(): Unit {
        // Layout(5, 3) -> align=3 -> no known type -> UInt8 fallback, arraySize=None -> size=5
        let layout = Layout(5, 3)
        let ts = Helpers.blob(unsafe { zeroValue<CjbindContext>() }, layout)
        let result = ts.toString()
        @Expect(result.contains("UInt8"), true)
    }
}

// === Union read/write helpers ===

@Test
public class UnionHelperTest {
    @TestCase
    func readHelperContainsFuncDecl(): Unit {
        let ts = Helpers.unionReadHelper("myField", tokenStreamFromTemplate("Int32"))
        let result = ts.toString()
        @Expect(result.contains("@C"), true)
        @Expect(result.contains("func __cjbind_read_myField"), true)
        @Expect(result.contains("CPointer<UInt8>"), true)
        @Expect(result.contains("Int32"), true)
        @Expect(result.contains("CPointer<Int32>"), true)
        @Expect(result.contains(".read()"), true)
    }

    @TestCase
    func writeHelperContainsFuncDecl(): Unit {
        let ts = Helpers.unionWriteHelper("myField", tokenStreamFromTemplate("Float64"))
        let result = ts.toString()
        @Expect(result.contains("@C"), true)
        @Expect(result.contains("func __cjbind_write_myField"), true)
        @Expect(result.contains("CPointer<UInt8>"), true)
        @Expect(result.contains("val: Float64"), true)
        @Expect(result.contains("CPointer<Float64>"), true)
        @Expect(result.contains(".write(val)"), true)
    }

    @TestCase
    func readHelperReturnType(): Unit {
        let ts = Helpers.unionReadHelper("u64val", tokenStreamFromTemplate("UInt64"))
        let result = ts.toString()
        @Expect(result.contains("): UInt64"), true)
    }

    @TestCase
    func writeHelperReturnUnit(): Unit {
        let ts = Helpers.unionWriteHelper("u64val", tokenStreamFromTemplate("UInt64"))
        let result = ts.toString()
        @Expect(result.contains("): Unit"), true)
    }
}

// === Bitfield read/write helpers ===

@Test
public class BitfieldHelperTest {
    @TestCase
    func readHelperSignature(): Unit {
        let ts = Helpers.bitfieldReadHelper()
        let result = ts.toString()
        @Expect(result.contains("@C"), true)
        @Expect(result.contains("func __cjbind_bitfield_read"), true)
        @Expect(result.contains("ptr: CPointer<UInt8>"), true)
        @Expect(result.contains("bitOffset: Int64"), true)
        @Expect(result.contains("bitWidth: Int64"), true)
        @Expect(result.contains("): UInt64"), true)
    }

    @TestCase
    func readHelperBitLogic(): Unit {
        let ts = Helpers.bitfieldReadHelper()
        let result = ts.toString()
        // Key bitfield extraction operations
        @Expect(result.contains("startByte = bitOffset / 8"), true)
        @Expect(result.contains("bitShift = bitOffset % 8"), true)
        @Expect(result.contains("bytesNeeded"), true)
        @Expect(result.contains(">> UInt64(bitShift)"), true)
    }

    @TestCase
    func readHelperMasking(): Unit {
        let ts = Helpers.bitfieldReadHelper()
        let result = ts.toString()
        // Mask for bitWidth < 64
        @Expect(result.contains("bitWidth < 64"), true)
        @Expect(result.contains("(UInt64(1) << UInt64(bitWidth)) - 1"), true)
    }

    @TestCase
    func writeHelperSignature(): Unit {
        let ts = Helpers.bitfieldWriteHelper()
        let result = ts.toString()
        @Expect(result.contains("@C"), true)
        @Expect(result.contains("func __cjbind_bitfield_write"), true)
        @Expect(result.contains("ptr: CPointer<UInt8>"), true)
        @Expect(result.contains("bitOffset: Int64"), true)
        @Expect(result.contains("bitWidth: Int64"), true)
        @Expect(result.contains("val: UInt64"), true)
        @Expect(result.contains("): Unit"), true)
    }

    @TestCase
    func writeHelperMaskAndWrite(): Unit {
        let ts = Helpers.bitfieldWriteHelper()
        let result = ts.toString()
        // Key write operations
        @Expect(result.contains("maskVal"), true)
        @Expect(result.contains("fieldMask"), true)
        @Expect(result.contains("byteVal"), true)
        @Expect(result.contains("byteMask"), true)
        @Expect(result.contains("(old &"), true)
    }

    @TestCase
    func readSignedHelperSignature(): Unit {
        let ts = Helpers.bitfieldReadSignedHelper()
        let result = ts.toString()
        @Expect(result.contains("func __cjbind_bitfield_read_signed"), true)
        @Expect(result.contains("): Int64"), true)
    }

    @TestCase
    func readSignedHelperSignExtension(): Unit {
        let ts = Helpers.bitfieldReadSignedHelper()
        let result = ts.toString()
        // Calls the unsigned reader
        @Expect(result.contains("__cjbind_bitfield_read(ptr, bitOffset, bitWidth)"), true)
        // Sign extension check
        @Expect(result.contains("bitWidth - 1"), true)
    }
}

// === AstTy ===

@Test
public class AstTyCVoidTest {
    @TestCase
    func returnsUnit(): Unit {
        let ts = AstTy.cVoid(unsafe { zeroValue<CjbindContext>() })
        @Expect(ts.toString(), "Unit")
    }
}

@Test
public class AstTyRawTypeTest {
    @TestCase
    func passthrough(): Unit {
        let ts = AstTy.rawType(unsafe { zeroValue<CjbindContext>() }, "MyCustomType")
        @Expect(ts.toString(), "MyCustomType")
    }
}

@Test
public class AstTyIntKindTest {
    @TestCase
    func boolType(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let ts = AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindBool, None)
        @Expect(ts.toString(), "Bool")
    }

    @TestCase
    func signedCharType(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let ts = AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindSChar, None)
        @Expect(ts.toString(), "Int8")
    }

    @TestCase
    func unsignedCharType(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let ts = AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindUChar, None)
        @Expect(ts.toString(), "UInt8")
    }

    @TestCase
    func charType(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let ts = AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindChar(true), None)
        @Expect(ts.toString(), "UInt8")
    }

    @TestCase
    func shortTypes(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindShort, None).toString(), "Int16")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindUShort, None).toString(), "UInt16")
    }

    @TestCase
    func intTypes(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindInt, None).toString(), "Int32")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindUInt, None).toString(), "UInt32")
    }

    @TestCase
    func longLongTypes(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindLongLong, None).toString(), "Int64")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindULongLong, None).toString(), "UInt64")
    }

    @TestCase
    func fixedWidthTypes(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindI8, None).toString(), "Int8")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindU8, None).toString(), "UInt8")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindI16, None).toString(), "Int16")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindU16, None).toString(), "UInt16")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindI32, None).toString(), "Int32")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindU32, None).toString(), "UInt32")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindI64, None).toString(), "Int64")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindU64, None).toString(), "UInt64")
    }

    @TestCase
    func i128Type(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindI128, None).toString()
        @Expect(result.contains("VArray"), true)
        @Expect(result.contains("Int64"), true)
        @Expect(result.contains("2"), true)
    }

    @TestCase
    func u128Type(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindU128, None).toString()
        @Expect(result.contains("VArray"), true)
        @Expect(result.contains("UInt64"), true)
    }

    @TestCase
    func longWithLayout4(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let layout = Layout(4, 4)
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindLong, layout).toString(), "Int32")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindULong, layout).toString(), "UInt32")
    }

    @TestCase
    func longWithLayout8(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let layout = Layout(8, 8)
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindLong, layout).toString(), "Int64")
        @Expect(AstTy.intKindCjType(ctx, TypeKindIntKind.IntKindULong, layout).toString(), "UInt64")
    }

    @TestCase
    func customType(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let custom = TypeKindIntKind.IntKindCustom(IntKindCustomValue("my_int_t", true))
        @Expect(AstTy.intKindCjType(ctx, custom, None).toString(), "my_int_t")
    }
}

@Test
public class AstTyFloatKindTest {
    @TestCase
    func float16(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        @Expect(AstTy.floatKindCjType(ctx, TypeKindFloatKind.FloatKindFloat16, None).toString(), "Float16")
    }

    @TestCase
    func floatType(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        @Expect(AstTy.floatKindCjType(ctx, TypeKindFloatKind.FloatKindFloat, None).toString(), "Float32")
    }

    @TestCase
    func doubleType(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        @Expect(AstTy.floatKindCjType(ctx, TypeKindFloatKind.FloatKindDouble, None).toString(), "Float64")
    }

    @TestCase
    func longDoubleSize4(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let layout = Layout(4, 4)
        @Expect(AstTy.floatKindCjType(ctx, TypeKindFloatKind.FloatKindLongDouble, layout).toString(), "Float32")
    }

    @TestCase
    func longDoubleSize8(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let layout = Layout(8, 8)
        @Expect(AstTy.floatKindCjType(ctx, TypeKindFloatKind.FloatKindLongDouble, layout).toString(), "Float64")
    }

    @TestCase
    func float128(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.floatKindCjType(ctx, TypeKindFloatKind.FloatKindFloat128, None).toString()
        @Expect(result.contains("VArray"), true)
        @Expect(result.contains("UInt64"), true)
    }
}

@Test
public class AstTyFloatExprTest {
    @TestCase
    func normalFloat(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.floatExpr(ctx, 3.14)
        @Expect(result.isOk(), true)
        let s = result.unwrap().toString()
        @Expect(s.contains("3.14"), true)
    }

    @TestCase
    func zeroIsNotNormal(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.floatExpr(ctx, 0.0)
        @Expect(result.isErr(), true)
    }

    @TestCase
    func negativeFloat(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.floatExpr(ctx, -2.5)
        @Expect(result.isOk(), true)
    }

    @TestCase
    func infinityIsNotNormal(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.floatExpr(ctx, Float64.Inf)
        @Expect(result.isErr(), true)
    }

    @TestCase
    func nanIsNotNormal(): Unit {
        let ctx = unsafe { zeroValue<CjbindContext>() }
        let result = AstTy.floatExpr(ctx, Float64.NaN)
        @Expect(result.isErr(), true)
    }
}
