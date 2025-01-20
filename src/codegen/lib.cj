package cjbind.codegen

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