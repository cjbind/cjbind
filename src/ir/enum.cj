package cjbind.ir

public enum EnumVariantValue {
    Boolean(Bool) |
    Signed(Int64) |
    Unsigned(UInt64)
}

public class EnumVariant {
    public let name: String
    public let comment: ?String
    public let val: EnumVariantValue

    public init(
        name: String,
        comment: ?String,
        val: EnumVariantValue
    ) {
        this.name = name
        this.comment = comment
        this.val = val
    }
}

public class TypeKindEnumKind {
    public let repr: ?TypeKind
    public let variants: Array<EnumVariant>

    public init(
        repr: ?TypeKind,
        variants: Array<EnumVariant>
    ) {
        this.repr = repr
        this.variants = variants
    }
}