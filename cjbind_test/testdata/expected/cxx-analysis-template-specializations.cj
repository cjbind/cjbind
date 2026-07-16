package cjbind_ffi

@C
public struct PartialDerived {
    public var primary: Bool
    private init(primary: Bool) {
        this.primary = primary
    }
}

@C
public struct TemplateSpecializationHolder {
    public let primary: ExplicitBox_open0_int_close0
    public let explicitSpecialization: ExplicitBox_open0_char_close0
    public let partialSpecialization: VArray<UInt64, $2>
    public let inheritedPartialSpecialization: VArray<UInt64, $2>
    private init(primary: ExplicitBox_open0_int_close0, explicitSpecialization: ExplicitBox_open0_char_close0,
        partialSpecialization: VArray<UInt64, $2>, inheritedPartialSpecialization: VArray<UInt64, $2>) {
        this.primary = primary
        this.explicitSpecialization = explicitSpecialization
        this.partialSpecialization = partialSpecialization
        this.inheritedPartialSpecialization = inheritedPartialSpecialization
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateSpecializationHolder>()
        if (size != 56) {
            throw Exception("Size of TemplateSpecializationHolder is not 56 but ${size} bytes")
        }
        let align = alignOf<TemplateSpecializationHolder>()
        if (align != 8) {
            throw Exception("Alignment of TemplateSpecializationHolder is not 8 but ${align} bytes")
        }
}

@C
public struct ExplicitBox_open0_char_close0 {
    public var value: Int64
    public var discriminator: UInt8
    private init(value: Int64, discriminator: UInt8) {
        this.value = value
        this.discriminator = discriminator
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ExplicitBox_open0_char_close0>()
        if (size != 16) {
            throw Exception("Size of ExplicitBox_open0_char_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<ExplicitBox_open0_char_close0>()
        if (align != 8) {
            throw Exception("Alignment of ExplicitBox_open0_char_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct ExplicitBox_open0_int_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ExplicitBox_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of ExplicitBox_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<ExplicitBox_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of ExplicitBox_open0_int_close0 is not 4 but ${align} bytes")
        }
}
