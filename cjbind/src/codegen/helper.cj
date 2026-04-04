package cjbind.codegen

import cjbind_token.*
import std.collection.collectArray

import cjbind.ir.*
import cjbind.result.Result

extend Tokens {
    func toPtr(): Tokens {
        return Tokens("CPointer<${this}>")
    }
}

public class Attributes {
    public static func doc(comment: String): Tokens {
        let lines = comment.lines() |> collectArray

        let ret = Tokens()

        for ((idx, line) in lines.iterator().enumerate()) {
            ret.append("//${line}")
            if (idx != lines.size - 1) {
                ret.append("\n")
            }
        }

        return ret
    }
}

public class Helpers {
    public static func blob(
        _: CjbindContext,
        layout: Layout
    ): Tokens {
        let opaque = layout.opaque()

        let ty = opaque.knownCjTypeForArray().getOrDefault {
            =>
            eprintln("Found unknown alignment on codegen")
            return Tokens("UInt8")
        }

        let dataLen = opaque.arraySize().getOrDefault {=> layout.size}

        if (dataLen == 1) {
            return ty
        } else {
            return Tokens("VArray<${ty}, \$${dataLen}>")
        }
    }

    public static func unionReadHelper(typeName: String, cjType: Tokens): Tokens {
        let funcName = "__cjbind_read_${typeName}"
        return Tokens(
            "@C\n" +
            "func ${funcName}(ptr: CPointer<UInt8>): ${cjType} {\n" +
            "    return unsafe { CPointer<${cjType}>(ptr).read() }\n" +
            "}"
        )
    }

    public static func unionWriteHelper(typeName: String, cjType: Tokens): Tokens {
        let funcName = "__cjbind_write_${typeName}"
        return Tokens(
            "@C\n" +
            "func ${funcName}(ptr: CPointer<UInt8>, val: ${cjType}): Unit {\n" +
            "    unsafe { CPointer<${cjType}>(ptr).write(val) }\n" +
            "}"
        )
    }

    public static func bitfieldReadHelper(): Tokens {
        return Tokens(
            "@C\n" +
            "func __cjbind_bitfield_read(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): UInt64 {\n" +
            "    let startByte = bitOffset / 8\n" +
            "    let bitShift = bitOffset % 8\n" +
            "    let bytesNeeded = (bitWidth + bitShift + 7) / 8\n" +
            "    var val: UInt64 = 0\n" +
            "    var i: Int64 = 0\n" +
            "    while (i < bytesNeeded) {\n" +
            "        val = val | (UInt64(unsafe { ptr.read(startByte + i) }) << UInt64(i * 8))\n" +
            "        i++\n" +
            "    }\n" +
            "    val = val >> UInt64(bitShift)\n" +
            "    if (bitWidth < 64) {\n" +
            "        val = val & ((UInt64(1) << UInt64(bitWidth)) - 1)\n" +
            "    }\n" +
            "    return val\n" +
            "}"
        )
    }

    public static func bitfieldWriteHelper(): Tokens {
        return Tokens(
            "@C\n" +
            "func __cjbind_bitfield_write(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64, val: UInt64): Unit {\n" +
            "    let startByte = bitOffset / 8\n" +
            "    let bitShift = bitOffset % 8\n" +
            "    let bytesNeeded = (bitWidth + bitShift + 7) / 8\n" +
            "    var maskVal = val\n" +
            "    if (bitWidth < 64) {\n" +
            "        maskVal = maskVal & ((UInt64(1) << UInt64(bitWidth)) - 1)\n" +
            "    }\n" +
            "    maskVal = maskVal << UInt64(bitShift)\n" +
            "    var fieldMask: UInt64 = if (bitWidth < 64) {\n" +
            "        ((UInt64(1) << UInt64(bitWidth)) - 1) << UInt64(bitShift)\n" +
            "    } else {\n" +
            "        !UInt64(0)\n" +
            "    }\n" +
            "    var i: Int64 = 0\n" +
            "    while (i < bytesNeeded) {\n" +
            "        let byteVal = UInt8((maskVal >> UInt64(i * 8)) & 0xFF)\n" +
            "        let byteMask = UInt8((fieldMask >> UInt64(i * 8)) & 0xFF)\n" +
            "        let old = unsafe { ptr.read(startByte + i) }\n" +
            "        unsafe { ptr.write(startByte + i, (old & !byteMask) | (byteVal & byteMask)) }\n" +
            "        i++\n" +
            "    }\n" +
            "}"
        )
    }

    public static func bitfieldReadSignedHelper(): Tokens {
        return Tokens(
            "@C\n" +
            "func __cjbind_bitfield_read_signed(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): Int64 {\n" +
            "    let raw = __cjbind_bitfield_read(ptr, bitOffset, bitWidth)\n" +
            "    if (bitWidth > 0 && bitWidth < 64 && (raw & (UInt64(1) << UInt64(bitWidth - 1))) != 0) {\n" +
            "        return Int64(raw | !((UInt64(1) << UInt64(bitWidth)) - 1))\n" +
            "    }\n" +
            "    return Int64(raw)\n" +
            "}"
        )
    }
}

public class AstTy {
    public static func cVoid(_: CjbindContext): Tokens {
        return Tokens("Unit")
    }

    public static func rawType(_: CjbindContext, name: String): Tokens {
        return Tokens(name)
    }

    public static func intKindCjType(
        ctx: CjbindContext,
        ik: TypeKindIntKind,
        layout: ?Layout
    ): Tokens {
        return match (ik) {
            case TypeKindIntKind.IntKindBool => Tokens("Bool")
            case TypeKindIntKind.IntKindChar(_) => rawType(ctx, "UInt8")
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
            case TypeKindIntKind.IntKindI8 => Tokens("Int8")
            case TypeKindIntKind.IntKindU8 => Tokens("UInt8")
            case TypeKindIntKind.IntKindI16 => Tokens("Int16")
            case TypeKindIntKind.IntKindU16 => Tokens("UInt16")
            case TypeKindIntKind.IntKindI32 => Tokens("Int32")
            case TypeKindIntKind.IntKindU32 => Tokens("UInt32")
            case TypeKindIntKind.IntKindI64 => Tokens("Int64")
            case TypeKindIntKind.IntKindU64 => Tokens("UInt64")
            case TypeKindIntKind.IntKindCustom(val) =>
                Tokens(val.name)
            case TypeKindIntKind.IntKindI128 =>
                Tokens("VArray<Int64, \$2>")
            case TypeKindIntKind.IntKindU128 =>
                Tokens("VArray<UInt64, \$2>")
        }
    }

    public static func floatKindCjType(
        _: CjbindContext,
        fk: TypeKindFloatKind,
        layout: ?Layout
    ): Tokens {
        return match (fk) {
            case TypeKindFloatKind.FloatKindFloat16 => Tokens("Float16")
            case TypeKindFloatKind.FloatKindFloat => Tokens("Float32")
            case TypeKindFloatKind.FloatKindDouble => Tokens("Float64")
            case TypeKindFloatKind.FloatKindLongDouble =>
                let l = layout.getOrThrow()
                match (l.size) {
                    case 4 => Tokens("Float32")
                    case 8 => Tokens("Float64")
                    case _ => Layout.knownCjTypeForSize(l.size).getOrDefault {
                        =>
                        Tokens("Float64")
                    }
                }
            case TypeKindFloatKind.FloatKindFloat128 =>
                Tokens("VArray<UInt64, \$2>")
        }
    }

    public static func floatExpr(
        _: CjbindContext,
        f: Float64
    ): Result<Tokens, Unit> {
        if (f.isNormal()) {
            return Ok(Tokens(float64Repr(f)))
        }

        return Err(())
    }
}
