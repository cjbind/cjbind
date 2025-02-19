package cjbind.codegen

import std.ast.*
import std.collection.{ArrayList, collectArrayList}
import cjbind.ir.*

public class Utils {
    public static func fnsigArguments(
        ctx: CjbindContext,
        sig: FunctionSig
    ): ArrayList<Tokens> {
        let unnamedArguments = Box(0)

        let argsIter = sig.argumentTypes.iterator()

        let args = argsIter.map {
            v =>
            let name = v[0]
            let ty = v[1]

            let argTy = fnsigArgumentType(ctx, ty)

            let argName = if (let Some(n) <- name) {
                ctx.cjMangle(n)
            } else {
                unnamedArguments.value += 1
                "arg${unnamedArguments.value}"
            }

            let argIdent = ctx.cjIdent(argName)

            return quote($(argIdent) : $(argTy))
        } |> collectArrayList

        return args
    }

    public static func fnsigArgumentNames(
        ctx: CjbindContext,
        sig: FunctionSig
    ): ArrayList<Tokens> {
        let unnamedArguments = Box(0)

        let argsIter = sig.argumentTypes.iterator()

        let args = argsIter.map {
            v =>
            let name = v[0]
            let argName = if (let Some(n) <- name) {
                ctx.cjMangle(n)
            } else {
                unnamedArguments.value += 1
                "arg${unnamedArguments.value}"
            }

            let argIdent = ctx.cjIdent(argName)

            return Tokens(argIdent)
        } |> collectArrayList

        return args
    }

    public static func fnsigArgumentType(
        ctx: CjbindContext,
        ty: TypeId
    ): Tokens {
        let argItem = ctx.resolveItem(ty)
        let argTy = argItem.kind.expectType()

        match (argTy.canonicalType(ctx).kind) {
            case TypeKind.TypeKindArray(t, _) =>
                let stream = if (ctx.options.arrayPointersInArgs) {
                    argTy.toCjTyOrOpaque(ctx, argItem)
                } else {
                    t.toCjTyOrOpaque(ctx, ()).toPtr()
                }
                return stream
            case _ => argItem.toCjTyOrOpaque(ctx, ())
        }
    }

    // TODO: add divergent support
    public static func fnsigReturnTy(
        ctx: CjbindContext,
        sig: FunctionSig
    ): Tokens {
        let canonicalTypeKind = sig
            .returnType
            .intoResolver()
            .throughTypeAliases()
            .throughTypeRefs()
            .resolve(ctx)
            .kind
            .expectType()
            .kind

        match (canonicalTypeKind) {
            case TypeKind.TypeKindVoid => quote(Unit)
            case _ => sig.returnType.toCjTyOrOpaque(ctx, ())
        }
    }

    static func primitiveTy(ctx: CjbindContext, name: String): Tokens {
        return Tokens(ctx.cjIdentRaw(name))
    }

    public static func typeFromNamed(
        ctx: CjbindContext,
        name: String
    ): ?Tokens {
        match (name) {
            case "int8_t" => primitiveTy(ctx, "Int8")
            case "uint8_t" => primitiveTy(ctx, "UInt8")
            case "int16_t" => primitiveTy(ctx, "Int16")
            case "uint16_t" => primitiveTy(ctx, "UInt16")
            case "int32_t" => primitiveTy(ctx, "Int32")
            case "uint32_t" => primitiveTy(ctx, "UInt32")
            case "int64_t" => primitiveTy(ctx, "Int64")
            case "uint64_t" => primitiveTy(ctx, "UInt64")
            
            case "size_t" => primitiveTy(ctx, "UIntNative")
            case "uintptr_t" => primitiveTy(ctx, "UIntNative")

            case "ssize_t" => primitiveTy(ctx, "IntNative")
            case "intptr_t" | "ptrdiff_t" => primitiveTy(ctx, "IntNative")
            case _ => None
        }
    }
}

func joinTokens(val: Collection<Tokens>, sep: Tokens): Tokens {
    let ret = Tokens()

    for (v in val.iterator().enumerate()) {
        ret.append(v[1])
        if (v[0] != val.size - 1) {
            ret.append(sep)
        }
    }

    return ret
}

func optionalComment(ctx: CjbindContext, comment: ?Tokens, body: Tokens): Tokens {
    if (let Some(v) <- comment && !ctx.options.noComment) {
        let tokens = v
        tokens.append(Token(TokenKind.NL))
        tokens.append(body)
        return tokens
    } else {
        return body
    }
}