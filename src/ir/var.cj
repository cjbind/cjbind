package cjbind.ir

import std.collection.ArrayList

public class Var {
    public let name: String
    public let ty: TypeId
    public let val: ?VarType
    public let isConst: Bool

    public init(
        name: String,
        ty: TypeId,
        val: ?VarType,
        isConst: Bool
    ) {
        this.name = name
        this.ty = ty
        this.val = val
        this.isConst = isConst
    }
}

public enum VarType {
    VarBool(Bool) |
    VarInt(Int64) |
    VarFloat(Float64) |
    VarChar(UInt8) |
    VarString(ArrayList<UInt8>)
}