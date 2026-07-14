package cjbind_ffi

@C
public struct ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0 {
    public let value: Int64
    public let discriminator: UInt8
    public func clone(): ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0 {
        return this
    }
    public func toString(): String {
        var output = "ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0 {"
        output += " value: "
        output += this.value.toString()
        output += ", discriminator: "
        output += this.discriminator.toString()
        output += " }"
        return output
    }
    public init(value: Int64, discriminator: UInt8) {
        this.value = value
        this.discriminator = discriminator
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0>()
        if (size != 16) {
            throw Exception(
                "Size of ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct PartialDerived_PartialDerived {
    public let primary: Bool
    public func clone(): PartialDerived_PartialDerived {
        return this
    }
    public func toString(): String {
        var output = "PartialDerived_PartialDerived {"
        output += " primary: "
        output += this.primary.toString()
        output += " }"
        return output
    }
    public init(primary: Bool) {
        this.primary = primary
    }
}

@C
public struct ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0 {
    public let value: Int32
    public func clone(): ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0 {
    public let pointer: CPointer<Int32>
    public let count: UInt32
    public func clone(): PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0 {
        return this
    }
    public func toString(): String {
        var output = "PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0 {"
        output += " pointer: "
        output += CPointer<Unit>(this.pointer).toUIntNative().toString()
        output += ", count: "
        output += this.count.toString()
        output += " }"
        return output
    }
    public init(pointer: CPointer<Int32>, count: UInt32) {
        this.pointer = pointer
        this.count = count
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0>()
        if (size != 16) {
            throw Exception(
                "Size of PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public func clone(): PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0 {
        return this
    }
    public func toString(): String {
        var output = "PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0>()
        if (size != 16) {
            throw Exception(
                "Size of PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct TemplateSpecializationHolder_TemplateSpecializationHolder {
    public let primary: ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0
    public let explicitSpecialization: ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0
    public let partialSpecialization: PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0
    public let inheritedPartialSpecialization: PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0
    public func clone(): TemplateSpecializationHolder_TemplateSpecializationHolder {
        return this
    }
    public func toString(): String {
        var output = "TemplateSpecializationHolder_TemplateSpecializationHolder {"
        output += " primary: "
        output += this.primary.toString()
        output += ", explicitSpecialization: "
        output += this.explicitSpecialization.toString()
        output += ", partialSpecialization: "
        output += this.partialSpecialization.toString()
        output += ", inheritedPartialSpecialization: "
        output += this.inheritedPartialSpecialization.toString()
        output += " }"
        return output
    }
    public init(primary: ExplicitBox_open0_int_close0_ExplicitBox_open0_int_close0,
        explicitSpecialization: ExplicitBox_open0_char_close0_ExplicitBox_open0_char_close0,
        partialSpecialization: PartialBox_open0_int_ptr_close0_PartialBox_open0_int_ptr_close0,
        inheritedPartialSpecialization: PartialDerived_open0_int_ptr_close0_PartialDerived_open0_int_ptr_close0) {
        this.primary = primary
        this.explicitSpecialization = explicitSpecialization
        this.partialSpecialization = partialSpecialization
        this.inheritedPartialSpecialization = inheritedPartialSpecialization
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateSpecializationHolder_TemplateSpecializationHolder>()
        if (size != 56) {
            throw Exception(
                "Size of TemplateSpecializationHolder_TemplateSpecializationHolder is not 56 but ${size} bytes")
        }
        let align = alignOf<TemplateSpecializationHolder_TemplateSpecializationHolder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateSpecializationHolder_TemplateSpecializationHolder is not 8 but ${align} bytes")
        }
}
