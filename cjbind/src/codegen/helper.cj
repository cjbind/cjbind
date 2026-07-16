package cjbind.codegen

import cjbind_token.*
import cjbind_token.macros.*
import std.collection.collectArray

import cjbind.ir.*
import cjbind.result.Result

extend TokenStream {
    func toPtr(): TokenStream {
        return tokenStreamFromTemplate("CPointer<${this}>")
    }
}

public class Attributes {
    public static func doc(comment: String): TokenStream {
        let lines = comment.lines() |> collectArray

        let ret = TokenStream()

        for ((idx, line) in lines.iterator().enumerate()) {
            ret.appendLiteral("//${line}")
            if (idx != lines.size - 1) {
                ret.appendLiteral("\n")
            }
        }

        return ret
    }
}

public class Helpers {
    public static func float16Type(): TokenStream {
        let output = TokenStream()
        output.appendLiteral(
            "// ABI storage for C _Float16 / __fp16 values. The value property is " +
            "a local bit view; Cangjie Float16 is still not a CType.\n"
        )
        output.`extend`(@tmpl(
            @C
            public struct __CjbindFloat16 {
                public var bits: UInt16

                public init(bits: UInt16) {
                    this.bits = bits
                }

                public init(value: Float16) {
                    this.bits = value.toBits()
                }

                public mut prop value: Float16 {
                    get() {
                        return Float16.fromBits(this.bits)
                    }
                    set(value) {
                        this.bits = value.toBits()
                    }
                }
            }
        ))
        return output
    }

    public static func complexTypes(): TokenStream {
        let output = TokenStream()
        output.appendLiteral(
            "// ABI-only memory carriers for C complex objects. Direct complex " +
            "parameters and return values are intentionally not generated.\n"
        )
        output.`extend`(@tmpl(
            @C
            public struct __CjbindComplexFloat16 {
                public var reBits: UInt16
                public var imBits: UInt16

                public init(reBits: UInt16, imBits: UInt16) {
                    this.reBits = reBits
                    this.imBits = imBits
                }

                public init(real: Float16, imaginary: Float16) {
                    this.reBits = real.toBits()
                    this.imBits = imaginary.toBits()
                }

                public mut prop real: Float16 {
                    get() {
                        return Float16.fromBits(this.reBits)
                    }
                    set(value) {
                        this.reBits = value.toBits()
                    }
                }

                public mut prop imaginary: Float16 {
                    get() {
                        return Float16.fromBits(this.imBits)
                    }
                    set(value) {
                        this.imBits = value.toBits()
                    }
                }
            }

            @C
            public struct __CjbindComplexFloat32 {
                public var re: Float32
                public var im: Float32

                public init(re: Float32, im: Float32) {
                    this.re = re
                    this.im = im
                }

                public mut prop real: Float32 {
                    get() {
                        return this.re
                    }
                    set(value) {
                        this.re = value
                    }
                }

                public mut prop imaginary: Float32 {
                    get() {
                        return this.im
                    }
                    set(value) {
                        this.im = value
                    }
                }
            }

            @C
            public struct __CjbindComplexFloat64 {
                public var re: Float64
                public var im: Float64

                public init(re: Float64, im: Float64) {
                    this.re = re
                    this.im = im
                }

                public mut prop real: Float64 {
                    get() {
                        return this.re
                    }
                    set(value) {
                        this.re = value
                    }
                }

                public mut prop imaginary: Float64 {
                    get() {
                        return this.im
                    }
                    set(value) {
                        this.im = value
                    }
                }
            }
        ))
        return output
    }

    public static func incompleteArrayViewType(): TokenStream {
        let output = TokenStream()
        let negativeSizeError = tokenStreamFromTemplate("\"array view size cannot be negative\"")
        let outOfBoundsError = tokenStreamFromTemplate("\"array view index out of bounds\"")
        output.appendLiteral(
            "// A bounded view over a C flexible or zero-length array. Construction " +
            "from an owning pointer and indexing stay unsafe because pointer validity and lifetime are caller contracts.\n"
        )
        output.`extend`(@tmpl(
            public struct __CjbindArrayView<T> where T <: CType {
                let _pointer: CPointer<T>
                let _size: Int64

                public init(pointer!: CPointer<T>, size!: Int64) {
                    this._pointer = pointer
                    this._size = size
                    if (size < 0) {
                        throw Exception(${negativeSizeError})
                    }
                }

                public prop pointer: CPointer<T> {
                    get() {
                        return this._pointer
                    }
                }

                public prop size: Int64 {
                    get() {
                        return this._size
                    }
                }

                public prop isEmpty: Bool {
                    get() {
                        return this._size == 0
                    }
                }

                public unsafe operator func [](index: Int64): T {
                    if (index < 0 || index >= this._size) {
                        throw Exception(${outOfBoundsError})
                    }
                    return this._pointer.read(index)
                }

                public unsafe operator func [](index: Int64, value!: T): Unit {
                    if (index < 0 || index >= this._size) {
                        throw Exception(${outOfBoundsError})
                    }
                    this._pointer.write(index, value)
                }
            }

            // CPointer cannot encode a pointer-to-const. Do not publicly expose
            // the pointer, and omit a setter so a const array does not acquire write access.
            public struct __CjbindConstArrayView<T> where T <: CType {
                let _pointer: CPointer<T>
                let _size: Int64

                init(pointer!: CPointer<T>, size!: Int64) {
                    this._pointer = pointer
                    this._size = size
                    if (size < 0) {
                        throw Exception(${negativeSizeError})
                    }
                }

                public prop size: Int64 {
                    get() {
                        return this._size
                    }
                }

                public prop isEmpty: Bool {
                    get() {
                        return this._size == 0
                    }
                }

                public unsafe operator func [](index: Int64): T {
                    if (index < 0 || index >= this._size) {
                        throw Exception(${outOfBoundsError})
                    }
                    return this._pointer.read(index)
                }
            }
        ))
        return output
    }

    public static func variadicFunctionTypeName(fixedArgumentCount: Int64): String {
        return "__CjbindVariadicFunction${fixedArgumentCount}"
    }

    public static func variadicFunctionAlias(fixedArgumentCount: Int64): TokenStream {
        let parameters = TokenStream()
        parameters.appendLiteral("R")
        for (index in 0..fixedArgumentCount) {
            parameters.appendLiteral(", A${index}")
        }
        let name = variadicFunctionTypeName(fixedArgumentCount)
        let output = TokenStream()
        output.appendLiteral(
            "// ABI-only opaque pointer for a C variadic callback. The generic " +
            "arguments document the source signature; this alias is not callable " +
            "from Cangjie.\n"
        )
        output.`extend`(tokenStreamFromTemplate(
            "public type ${name}<${parameters}> = CPointer<Unit>"
        ))
        return output
    }

    public static func blob(
        _: CjbindContext,
        layout: Layout
    ): TokenStream {
        let opaque = layout.opaque()

        let ty = opaque.knownCjTypeForArray().getOrDefault {
            =>
            eprintln("Found unknown alignment on codegen")
            return tokenStreamFromTemplate("UInt8")
        }

        let dataLen = opaque.arraySize().getOrDefault {=> layout.size}

        if (dataLen == 1) {
            return ty
        } else {
            return tokenStreamFromTemplate("VArray<${ty}, \$${dataLen}>")
        }
    }

    public static func unionHelperSuffix(_: CjbindContext, cjType: TokenStream): String {
        let compact = cjType.toString().replace(" ", "")
        return compact
            .replace("<", "_")
            .replace(">", "_")
            .replace(",", "_")
            .replace("$", "_")
            .replace(".", "_")
            .replace(":", "_")
            .replace("[", "_")
            .replace("]", "_")
            .replace("(", "_")
            .replace(")", "_")
            .replace("@", "_")
            .replace("?", "_")
    }

    public static func unionReadHelper(typeName: String, storageTy: TokenStream, cjType: TokenStream): TokenStream {
        let funcName = "__cjbind_read_${typeName}"
        return @tmpl(
            func ${funcName}(storage: ${storageTy}): ${cjType} {
                var s = storage
                return unsafe { CPointer<${cjType}>(CPointer<UInt8>(inout s)).read() }
            }
        )
    }

    public static func unionWriteHelper(typeName: String, storageTy: TokenStream, cjType: TokenStream): TokenStream {
        let funcName = "__cjbind_write_${typeName}"
        return @tmpl(
            func ${funcName}(storage: ${storageTy}, val: ${cjType}): ${storageTy} {
                var s = storage
                unsafe { CPointer<${cjType}>(CPointer<UInt8>(inout s)).write(val) }
                return s
            }
        )
    }

    public static func unionReadPointerHelper(typeName: String, cjType: TokenStream): TokenStream {
        let funcName = "__cjbind_read_${typeName}"
        return @tmpl(
            func ${funcName}(ptr: CPointer<UInt8>): ${cjType} {
                return unsafe { CPointer<${cjType}>(ptr).read() }
            }
        )
    }

    public static func unionWritePointerHelper(typeName: String, cjType: TokenStream): TokenStream {
        let funcName = "__cjbind_write_${typeName}"
        return @tmpl(
            func ${funcName}(ptr: CPointer<UInt8>, val: ${cjType}): Unit {
                unsafe { CPointer<${cjType}>(ptr).write(val) }
            }
        )
    }

    public static func bitfieldReadHelper(): TokenStream {
        return @tmpl(
            @C
            func __cjbind_bitfield_read(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): UInt64 {
                let startByte = bitOffset / 8
                let bitShift = bitOffset % 8
                let bytesNeeded = (bitWidth + bitShift + 7) / 8
                var val: UInt64 = 0
                var i: Int64 = 0
                while (i < bytesNeeded) {
                    val = val | (UInt64(unsafe { ptr.read(startByte + i) }) << UInt64(i * 8))
                    i++
                }
                val = val >> UInt64(bitShift)
                if (bitWidth < 64) {
                    val = val & ((UInt64(1) << UInt64(bitWidth)) - 1)
                }
                return val
            }
        )
    }

    public static func bitfieldWriteHelper(): TokenStream {
        return @tmpl(
            @C
            func __cjbind_bitfield_write(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64, val: UInt64): Unit {
                let startByte = bitOffset / 8
                let bitShift = bitOffset % 8
                let bytesNeeded = (bitWidth + bitShift + 7) / 8
                var maskVal = val
                if (bitWidth < 64) {
                    maskVal = maskVal & ((UInt64(1) << UInt64(bitWidth)) - 1)
                }
                maskVal = maskVal << UInt64(bitShift)
                var fieldMask: UInt64 = if (bitWidth + bitShift < 64) {
                    ((UInt64(1) << UInt64(bitWidth)) - 1) << UInt64(bitShift)
                } else {
                    !UInt64(0) << UInt64(bitShift)
                }
                var i: Int64 = 0
                while (i < bytesNeeded) {
                    let byteVal = UInt8((maskVal >> UInt64(i * 8)) & 0xFF)
                    let byteMask = UInt8((fieldMask >> UInt64(i * 8)) & 0xFF)
                    let old = unsafe { ptr.read(startByte + i) }
                    unsafe { ptr.write(startByte + i, (old & !byteMask) | (byteVal & byteMask)) }
                    i++
                }
            }
        )
    }

    public static func bitfieldReadSignedHelper(): TokenStream {
        return @tmpl(
            @C
            func __cjbind_bitfield_read_signed(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): Int64 {
                let raw = unsafe { __cjbind_bitfield_read(ptr, bitOffset, bitWidth) }
                if (bitWidth > 0 && bitWidth < 64 && (raw & (UInt64(1) << UInt64(bitWidth - 1))) != 0) {
                    let extended = raw | !((UInt64(1) << UInt64(bitWidth)) - 1)
                    return unsafe { __cjbind_bitfield_uint64_to_int64(extended) }
                }
                return unsafe { __cjbind_bitfield_uint64_to_int64(raw) }
            }
        )
    }

    public static func bitfieldSignedConversionHelpers(): TokenStream {
        return @tmpl(
            @C
            func __cjbind_bitfield_int64_to_uint64(value: Int64): UInt64 {
                var copy = value
                return unsafe { CPointer<UInt64>(CPointer<Int64>(inout copy)).read() }
            }

            @C
            func __cjbind_bitfield_uint64_to_int64(value: UInt64): Int64 {
                var copy = value
                return unsafe { CPointer<Int64>(CPointer<UInt64>(inout copy)).read() }
            }
        )
    }
}

public class AstTy {
    public static func complexKindCjType(
        _: CjbindContext,
        fk: TypeKindFloatKind,
        layout: ?Layout
    ): ?TokenStream {
        return match (fk) {
            case TypeKindFloatKind.FloatKindFloat16 =>
                Some(tokenStreamFromTemplate("__CjbindComplexFloat16"))
            case TypeKindFloatKind.FloatKindFloat =>
                Some(tokenStreamFromTemplate("__CjbindComplexFloat32"))
            case TypeKindFloatKind.FloatKindDouble =>
                Some(tokenStreamFromTemplate("__CjbindComplexFloat64"))
            case TypeKindFloatKind.FloatKindLongDouble =>
                match (layout) {
                    case Some(value) =>
                        let componentSize = value.size / 2
                        match (componentSize) {
                            case 4 => Some(tokenStreamFromTemplate("__CjbindComplexFloat32"))
                            case 8 => Some(tokenStreamFromTemplate("__CjbindComplexFloat64"))
                            case _ => None
                        }
                    case None => None
                }
            case TypeKindFloatKind.FloatKindFloat128 => None
        }
    }

    public static func cVoid(_: CjbindContext): TokenStream {
        return tokenStreamFromTemplate("Unit")
    }

    public static func rawType(_: CjbindContext, name: String): TokenStream {
        return tokenStreamFromTemplate(name)
    }

    public static func intKindCjType(
        ctx: CjbindContext,
        ik: TypeKindIntKind,
        layout: ?Layout
    ): TokenStream {
        return match (ik) {
            case TypeKindIntKind.IntKindBool => tokenStreamFromTemplate("Bool")
            case TypeKindIntKind.IntKindChar(_) => rawType(ctx, "UInt8")
            case TypeKindIntKind.IntKindChar16 => rawType(ctx, "UInt16")
            case TypeKindIntKind.IntKindSChar => rawType(ctx, "Int8")
            case TypeKindIntKind.IntKindUChar => rawType(ctx, "UInt8")
            case TypeKindIntKind.IntKindShort => rawType(ctx, "Int16")
            case TypeKindIntKind.IntKindUShort => rawType(ctx, "UInt16")
            case TypeKindIntKind.IntKindInt => rawType(ctx, "Int32")
            case TypeKindIntKind.IntKindUInt => rawType(ctx, "UInt32")
            case TypeKindIntKind.IntKindLong =>
                let longLayout = match (layout) {
                    case Some(l) => l
                    case None =>
                        eprintln("Warning: missing layout for long type, defaulting to 8 bytes")
                        Layout(8, 8)
                }
                match (longLayout.size) {
                    case 4 => rawType(ctx, "Int32")
                    case 8 => rawType(ctx, "Int64")
                    case _ => rawType(ctx, "Int64")
                }
            case TypeKindIntKind.IntKindULong =>
                let ulongLayout = match (layout) {
                    case Some(l) => l
                    case None =>
                        eprintln("Warning: missing layout for ulong type, defaulting to 8 bytes")
                        Layout(8, 8)
                }
                match (ulongLayout.size) {
                    case 4 => rawType(ctx, "UInt32")
                    case 8 => rawType(ctx, "UInt64")
                    case _ => rawType(ctx, "UInt64")
                }
            case TypeKindIntKind.IntKindLongLong => rawType(ctx, "Int64")
            case TypeKindIntKind.IntKindULongLong => rawType(ctx, "UInt64")
            case TypeKindIntKind.IntKindWChar(_) =>
                let wcharLayout = match (layout) {
                    case Some(l) => l
                    case None =>
                        eprintln("Warning: missing layout for wchar type, defaulting to 8 bytes")
                        Layout(8, 8)
                }
                Layout.knownCjTypeForSize(wcharLayout.size).getOrThrow()
            case TypeKindIntKind.IntKindI8 => tokenStreamFromTemplate("Int8")
            case TypeKindIntKind.IntKindU8 => tokenStreamFromTemplate("UInt8")
            case TypeKindIntKind.IntKindI16 => tokenStreamFromTemplate("Int16")
            case TypeKindIntKind.IntKindU16 => tokenStreamFromTemplate("UInt16")
            case TypeKindIntKind.IntKindI32 => tokenStreamFromTemplate("Int32")
            case TypeKindIntKind.IntKindU32 => tokenStreamFromTemplate("UInt32")
            case TypeKindIntKind.IntKindI64 => tokenStreamFromTemplate("Int64")
            case TypeKindIntKind.IntKindU64 => tokenStreamFromTemplate("UInt64")
            case TypeKindIntKind.IntKindCustom(val) =>
                tokenStreamFromTemplate(val.name)
            case TypeKindIntKind.IntKindI128 =>
                tokenStreamFromTemplate("VArray<Int64, \$2>")
            case TypeKindIntKind.IntKindU128 =>
                tokenStreamFromTemplate("VArray<UInt64, \$2>")
        }
    }

    public static func floatKindCjType(
        _: CjbindContext,
        fk: TypeKindFloatKind,
        layout: ?Layout
    ): TokenStream {
        return match (fk) {
            case TypeKindFloatKind.FloatKindFloat16 =>
                tokenStreamFromTemplate("__CjbindFloat16")
            case TypeKindFloatKind.FloatKindFloat => tokenStreamFromTemplate("Float32")
            case TypeKindFloatKind.FloatKindDouble => tokenStreamFromTemplate("Float64")
            case TypeKindFloatKind.FloatKindLongDouble =>
                let l = layout.getOrThrow()
                match (l.size) {
                    case 4 => tokenStreamFromTemplate("Float32")
                    case 8 => tokenStreamFromTemplate("Float64")
                    case _ => Layout.knownCjTypeForSize(l.size).getOrDefault {
                        =>
                        tokenStreamFromTemplate("Float64")
                    }
                }
            case TypeKindFloatKind.FloatKindFloat128 =>
                tokenStreamFromTemplate("VArray<UInt64, \$2>")
        }
    }

    public static func floatExpr(
        _: CjbindContext,
        f: Float64
    ): Result<TokenStream, Unit> {
        if (f.isNormal()) {
            return Ok(tokenStreamFromTemplate("${f}".replace("+", "")))
        }

        return Err(())
    }
}
