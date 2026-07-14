package cjbind_ffi

@C
public struct PartialDerived {
    public let primary: Bool
    public init(primary: Bool) {
        this.primary = primary
    }
}

@C
public struct TemplateSpecializationHolder {
    public let primary: ExplicitBox_open0_int_close0
    public let explicitSpecialization: ExplicitBox_open0_char_close0
    public let partialSpecialization: VArray<UInt64, $2>
    public let inheritedPartialSpecialization: VArray<UInt64, $2>
    public init(primary: ExplicitBox_open0_int_close0, explicitSpecialization: ExplicitBox_open0_char_close0,
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
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
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
    public let value: Int32
    public init(value: Int32) {
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
