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
    | IntKindWChar(Bool) // isSigned
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

    public func isSigned(): ?Bool {
        match (this) {
            case IntKindBool | IntKindUChar | IntKindUShort | IntKindUInt | IntKindULong | IntKindULongLong | IntKindU8 | IntKindU16 | IntKindU32 | IntKindU64 | IntKindU128 => Some(false)
            case IntKindSChar | IntKindShort | IntKindInt | IntKindLong | IntKindLongLong | IntKindI8 | IntKindI16 | IntKindI32 | IntKindI64 | IntKindI128 => Some(true)
            case IntKindWChar(signed) => Some(signed)
            case IntKindChar(v) => Some(v)
            case IntKindCustom(v) => Some(v.isSigned)
        }
    }

    public func knownSize(): ?UIntNative {
        return match (this) {
            case IntKindBool | IntKindUChar | IntKindSChar | IntKindU8 | IntKindI8 | IntKindChar(_) => 1
            case IntKindU16 | IntKindI16 => 2
            case IntKindU32 | IntKindI32 => 4
            case IntKindU64 | IntKindI64 => 8
            case IntKindI128 | IntKindU128 => 16
            case _ => None
        }
    }

    public func signednessMatches(nonNegative: Bool): Bool {
        let signed = this.isSigned().getOrDefault({=> false})
        return nonNegative || signed
    }

    public func isChar(): Bool {
        return match (this) {
            case IntKindChar(_) | IntKindSChar | IntKindUChar => true
            case _ => false
        }
    }
}
