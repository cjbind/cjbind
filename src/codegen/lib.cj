package cjbind.codegen

import std.ast.*

import cjbind.ir.*
import cjbind.options.CjbindOptions
import cjbind.result.Result

public struct CodegenSerializeError {
    public let msg: String
    public let loc: String

    public init(
        msg: String,
        loc: String
    ) {
        this.msg = msg
        this.loc = loc
    }
}

public enum CodegenError {
    Serialize(CodegenSerializeError) |
    Io(String)
}

public func codegen(
    context: CjbindContext
): Result<(Tokens, CjbindOptions), CodegenError> {
    
}