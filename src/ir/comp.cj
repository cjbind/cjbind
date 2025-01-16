package cjbind.ir

public enum CompKind {
    CompKindUnion
}

public class CompInfo {
    public let kind: CompKind = CompKindUnion
    public let fields: CompFields
    public let packedAtter: Bool
    public let isForwardDeclaration: Bool

    public init(
        fields: CompFields,
        packedAtter!: Bool = false,
        isForwardDeclaration!: Bool = false
    ) {
        this.fields = fields
        this.packedAtter = packedAtter
        this.isForwardDeclaration = isForwardDeclaration
    }

    public func isUnion(): Bool {
        match (kind) {
            case CompKindUnion => true
            // case _ => false
        }
    }
}

public open class FieldData {
    public let name: ?String
    public let ty: TypeId
    public let comment: ?String
    public let bitfieldWidth: ?UInt32
    public let offset: UIntNative

    public init(
        name: ?String,
        ty: TypeId,
        comment: ?String,
        bitfieldWidth: ?UInt32,
        offset: UIntNative
    ) {
        this.name = name
        this.ty = ty
        this.comment = comment
        this.bitfieldWidth = bitfieldWidth
        this.offset = offset
    }
} 

public class RawField <: FieldData {
    public init(
        name: ?String,
        ty: TypeId,
        comment: ?String,
        bitfieldWidth: ?UInt32,
        offset: UIntNative
    ) {
        super(name, ty, comment, bitfieldWidth, offset)
    }
}

public class Bitfield {
    public let offsetIntoUnit: UIntNative
    public let data: FieldData
    public let getterName: ?String = None
    public let setterName: ?String = None

    public init(
        offsetIntoUnit: UIntNative,
        data: FieldData
    ) {
        this.offsetIntoUnit = offsetIntoUnit
        this.data = data
    }
}

public class BitfieldUnit {
    public let nth: UIntNative
    public let layout: Layout
    public let bitfields: Array<Bitfield>

    public init(
        nth: UIntNative,
        layout: Layout,
        bitfields: Array<Bitfield>
    ) {
        this.nth = nth
        this.layout = layout
        this.bitfields = bitfields
    }
}

public enum Field {
    DataMember(FieldData) |
    Bitfields(BitfieldUnit)
}

public struct CompFieldsAfterValue {
    public let fields: Array<Field>
    public let hasBitfieldUnits: Bool

    public init(
        fields: Array<Field>,
        hasBitfieldUnits: Bool
    ) {
        this.fields = fields
        this.hasBitfieldUnits = hasBitfieldUnits
    }
}

public enum CompFields {
    CompFieldsBefore(Array<RawField>) |
    CompFieldsAfter(CompFieldsAfterValue) |
    CompFieldsError
}