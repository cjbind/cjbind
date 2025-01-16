package cjbind.ir

public struct IntKindCustomValue {
    public let name: String
    public let isSigned: Bool

    public init(name: String, isSigned: Bool) {
        this.name = name
        this.isSigned = isSigned
    }
}

public enum TypeKindIntKind {
    IntKindBool
    | IntKindSChar
    | IntKindUChar
    | IntKindWChar
    | IntKindChar(Bool) // signed or not
    | IntKindShort
    | IntKindUShort
    | IntKindInt
    | IntKindUInt
    | IntKindLong
    | IntKindULong
    | IntKindLongLong
    | IntKindULongLong
    | IntKindI8
    | IntKindU8
    | IntKindI16
    | IntKindU16
    | IntKindI32
    | IntKindU32
    | IntKindI64
    | IntKindU64
    | IntKindI128
    | IntKindU128
    | IntKindCustom(IntKindCustomValue)
}
