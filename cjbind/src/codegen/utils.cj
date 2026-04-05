package cjbind.codegen

import cjbind_token.*
import std.collection.{ArrayList, collectArrayList}
import cjbind.ir.*

public class Utils {
    public static func fnsigArguments(
        ctx: CjbindContext,
        sig: FunctionSig
    ): ArrayList<TokenStream> {
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

            return tokenStreamFromTemplate("${argIdent}: ${argTy}")
        } |> collectArrayList

        return args
    }

    public static func fnsigArgumentNames(
        ctx: CjbindContext,
        sig: FunctionSig
    ): ArrayList<TokenStream> {
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

            return tokenStreamFromTemplate(argIdent)
        } |> collectArrayList

        return args
    }

    public static func fnsigArgumentType(
        ctx: CjbindContext,
        ty: TypeId
    ): TokenStream {
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
    ): TokenStream {
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
            case TypeKind.TypeKindVoid => tokenStreamFromTemplate("Unit")
            case _ => sig.returnType.toCjTyOrOpaque(ctx, ())
        }
    }

    static func primitiveTy(_: CjbindContext, name: String): TokenStream {
        return tokenStreamFromTemplate(name)
    }

    public static func typeFromNamed(
        ctx: CjbindContext,
        name: String
    ): ?TokenStream {
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

            // ObjC type mappings
            case "BOOL" => primitiveTy(ctx, "Bool")
            case "NSInteger" => primitiveTy(ctx, "IntNative")
            case "NSUInteger" => primitiveTy(ctx, "UIntNative")
            case "CGFloat" => primitiveTy(ctx, "Float64")
            case "NSTimeInterval" => primitiveTy(ctx, "Float64")
            case _ => None
        }
    }
}

func optionalComment(ctx: CjbindContext, comment: ?TokenStream, body: TokenStream): TokenStream {
    if (let Some(v) <- comment && !ctx.options.noComment) {
        let tokens = TokenStream()
        tokens.`extend`(v)
        tokens.appendLiteral("\n")
        tokens.`extend`(body)
        return tokens
    } else {
        return body
    }
}
