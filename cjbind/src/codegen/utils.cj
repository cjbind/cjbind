package cjbind.codegen

import cjbind_token.*
import std.collection.{ArrayList, HashSet}
import cjbind.ir.*

// Allocate names for the whole signature before emitting either declarations
// or calls. Reserve explicit names first so an unnamed argument cannot steal
// a name from a later parameter, including after Cangjie keyword mangling.
func uniqueFunctionArgumentNames(
    sig: FunctionSig,
    mangle: (String) -> String,
    unnamedPrefix: String,
    reservedNames!: Array<String> = []
): Array<String> {
    let reserved = HashSet<String>()
    for ((name, _) in sig.argumentTypes) {
        if (let Some(value) <- name && !value.isEmpty()) {
            reserved.add(mangle(value))
        }
    }

    let used = HashSet<String>(reservedNames)
    let names = ArrayList<String>()
    var unnamed = 0
    for ((name, _) in sig.argumentTypes) {
        var candidate = if (let Some(value) <- name && !value.isEmpty()) {
            mangle(value)
        } else {
            unnamed += 1
            var generated = "${unnamedPrefix}${unnamed}"
            while (reserved.contains(generated) || used.contains(generated)) {
                unnamed += 1
                generated = "${unnamedPrefix}${unnamed}"
            }
            generated
        }
        if (used.contains(candidate)) {
            let base = candidate
            var suffix = 1
            candidate = "${base}_${suffix}"
            while (reserved.contains(candidate) || used.contains(candidate)) {
                suffix += 1
                candidate = "${base}_${suffix}"
            }
        }
        used.add(candidate)
        names.add(candidate)
    }
    return names.toArray()
}

public class Utils {
    public static func fnsigArgumentIdentifiers(
        ctx: CjbindContext,
        sig: FunctionSig,
        reservedNames!: Array<String> = []
    ): Array<String> {
        return uniqueFunctionArgumentNames(sig, {name => ctx.cjIdent(name)}, "arg", reservedNames: reservedNames)
    }

    public static func fnsigArguments(
        ctx: CjbindContext,
        sig: FunctionSig,
        reservedNames!: Array<String> = []
    ): ArrayList<TokenStream> {
        let names = fnsigArgumentIdentifiers(ctx, sig, reservedNames: reservedNames)
        let args = ArrayList<TokenStream>()
        for (index in 0..sig.argumentTypes.size) {
            let argTy = fnsigArgumentType(ctx, sig.argumentTypes[index][1])
            args.add(tokenStreamFromTemplate("${names[index]}: ${argTy}"))
        }
        return args
    }

    public static func fnsigArgumentNames(
        ctx: CjbindContext,
        sig: FunctionSig,
        reservedNames!: Array<String> = []
    ): ArrayList<TokenStream> {
        let args = ArrayList<TokenStream>()
        for (name in fnsigArgumentIdentifiers(ctx, sig, reservedNames: reservedNames)) {
            args.add(tokenStreamFromTemplate(name))
        }
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

            case "size_t" =>
                if (ctx.options.sizeTIsUsize) {
                    primitiveTy(ctx, "UIntNative")
                } else {
                    None
                }
            case "uintptr_t" => primitiveTy(ctx, "UIntNative")

            case "ssize_t" =>
                if (ctx.options.sizeTIsUsize) {
                    primitiveTy(ctx, "IntNative")
                } else {
                    None
                }
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
