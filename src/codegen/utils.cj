package cjbind.codegen

import std.ast.*
import std.collection.ArrayList
import cjbind.ir.*

public class Utils {
    public static func fnsigArguments(
        ctx: CjbindContext,
        sig: FunctionSig
    ): ArrayList<Tokens> {
        var unnamedArguments = 0

        let argsIter = sig.argumentTypes.iterator()

        

        throw Exception("TODO")
    }

    public static func fnsigArgumentType(
        ctx: CjbindContext,
        ty: TypeId
    ): Tokens {
        let argItem = ctx.resolveItem(ty)
        let argTy = argItem.kind.expectType()

        match (argTy.canonicalType(ctx).kind) {
            case TypeKind.TypeKindArray(t, _) =>
            
        }


        throw Exception("TODO")
    }
}
