package cjbind.codegen

import std.ast.*
import std.collection.collectArray

import cjbind.ir.*
import cjbind.result.Result

extend Tokens {
    func toPtr(): Tokens {
        let v = this
        return quote(CPointer<$(v)>)
    }
}

public class Attributes {
    public static func doc(comment: String): Tokens {
        let lines = comment.lines() |> collectArray

        let ret = Tokens()

        for ((idx, line) in lines.iterator().enumerate()) {
            let val = "//" + line
            ret.append(Token(TokenKind.COMMENT, val))
            if (idx != lines.size - 1) {
                ret.append(Token(TokenKind.NL))
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
            return quote(UInt8)
        }

        let dataLen = opaque.arraySize().getOrDefault {=> layout.size}

        if (dataLen == 1) {
            return ty.toTokens()
        } else {
            return quote(VArray<$(ty), \$$(dataLen)>)
        }
    }
}

public class AstTy {
    public static func cVoid(_: CjbindContext): Tokens {
        return quote(Unit)
    }

    public static func rawType(ctx: CjbindContext, name: String): Tokens {
        let ident = ctx.cjIdentRaw(name)
        
        return quote($(ident))
    }

    public static func intKindCjType(
        ctx: CjbindContext,
        ik: TypeKindIntKind,
        layout: ?Layout
    ): Tokens {
        return match (ik) {
            case TypeKindIntKind.IntKindBool => quote(Bool)
            case TypeKindIntKind.IntKindChar(_) => rawType(ctx, "UInt8")
            case TypeKindIntKind.IntKindSChar => rawType(ctx, "Int8")
            case TypeKindIntKind.IntKindUChar => rawType(ctx, "UInt8")
            case TypeKindIntKind.IntKindShort => rawType(ctx, "Int16")
            case TypeKindIntKind.IntKindUShort => rawType(ctx, "UInt16")
            case TypeKindIntKind.IntKindInt => rawType(ctx, "Int32")
            case TypeKindIntKind.IntKindUInt => rawType(ctx, "UInt32")
            case TypeKindIntKind.IntKindLong => rawType(ctx, "Int64")
            case TypeKindIntKind.IntKindULong => rawType(ctx, "UInt64")
            case TypeKindIntKind.IntKindLongLong => rawType(ctx, "Int64")
            case TypeKindIntKind.IntKindULongLong => rawType(ctx, "UInt64")
            case TypeKindIntKind.IntKindWChar =>
                Layout.knownCjTypeForSize(layout.getOrThrow().size).getOrThrow()
            case TypeKindIntKind.IntKindI8 => quote(Int8)
            case TypeKindIntKind.IntKindU8 => quote(UInt8)
            case TypeKindIntKind.IntKindI16 => quote(Int16)
            case TypeKindIntKind.IntKindU16 => quote(UInt16)
            case TypeKindIntKind.IntKindI32 => quote(Int32)
            case TypeKindIntKind.IntKindU32 => quote(UInt32)
            case TypeKindIntKind.IntKindI64 => quote(Int64)
            case TypeKindIntKind.IntKindU64 => quote(UInt64)
            case TypeKindIntKind.IntKindCustom(val) =>
                let name = val.name
                quote($(name))
            case TypeKindIntKind.IntKindI128 =>
                quote(VArray<Int64, \$2>)
            case TypeKindIntKind.IntKindU128 =>
                quote(VArray<UInt64, \$2>)
        }
    }

    public static func floatKindCjType(
        _: CjbindContext,
        fk: TypeKindFloatKind,
        layout: ?Layout
    ): Tokens {
        return match (fk) {
            case TypeKindFloatKind.FloatKindFloat16 => quote(Float16)
            case TypeKindFloatKind.FloatKindFloat => quote(Float32)
            case TypeKindFloatKind.FloatKindDouble => quote(Float64)
            case TypeKindFloatKind.FloatKindLongDouble =>
                let l = layout.getOrThrow()
                match (l.size) {
                    case 4 => quote(Float32)
                    case 8 => quote(Float64)
                    case _ => Layout.knownCjTypeForSize(l.size).getOrDefault {
                        =>
                        // boom!
                        quote(Float64)
                    }
                }
            case TypeKindFloatKind.FloatKindFloat128 =>
                quote(VArray<UInt64, \$2>)
        }
    }

    public static func floatExpr(
        _: CjbindContext,
        f: Float64
    ): Result<Tokens, Unit> {
        if (f.isNormal()) {
            return Ok(quote($(f)))
        }

        // 暂时处理不了
        // TODO: 等待添加 Nan 和 Finity 字面量支持
        // https://gitcode.com/Cangjie/UsersForum/issues/1603
        return Err(())
    }
}