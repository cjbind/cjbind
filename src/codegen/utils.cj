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

        let args = 

        throw Exception("TODO")
    }
}
