package cjbind_ffi

@C
public struct PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $5>
    public func clone(): PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0>()
        if (size != 5) {
            throw Exception(
                "Size of PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0 is not 5 but ${size} bytes")
        }
        let align = alignOf<PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0>()
        if (align != 1) {
            throw Exception(
                "Alignment of PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0 {
    let _cjbind_opaque_blob: VArray<UInt16, $5>
    public func clone(): NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0 {
        return this
    }
    public func toString(): String {
        var output = "NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0>()
        if (size != 10) {
            throw Exception(
                "Size of NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0 is not 10 but ${size} bytes")
        }
        let align = alignOf<NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0 {
    let _cjbind_opaque_blob: UInt32
    public func clone(): SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0 {
    public let value: Float32
    public func clone(): SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0 {
        return this
    }
    public func toString(): String {
        var output = "SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Float32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0>()
        if (size != 4) {
            throw Exception(
                "Size of SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateOpacityHolder_TemplateOpacityHolder {
    public let packed: PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0
    public let dependentBitfield: DependentBitfield_DependentBitfield
    public let nonType: NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0
    public let selectedOpaque: SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0
    public let visible: SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0
    public func clone(): TemplateOpacityHolder_TemplateOpacityHolder {
        return this
    }
    public func toString(): String {
        var output = "TemplateOpacityHolder_TemplateOpacityHolder {"
        output += " packed: "
        output += this.packed.toString()
        output += ", dependentBitfield: "
        output += this.dependentBitfield.toString()
        output += ", nonType: "
        output += this.nonType.toString()
        output += ", selectedOpaque: "
        output += this.selectedOpaque.toString()
        output += ", visible: "
        output += this.visible.toString()
        output += " }"
        return output
    }
    public init(packed: PackedTemplate_open0_int_close0_PackedTemplate_open0_int_close0,
        dependentBitfield: DependentBitfield_DependentBitfield,
        nonType: NonTypeTemplate_open0_5_close0_NonTypeTemplate_open0_5_close0,
        selectedOpaque: SelectiveOpaque_open0_int_close0_SelectiveOpaque_open0_int_close0,
        visible: SelectiveOpaque_open0_float_close0_SelectiveOpaque_open0_float_close0) {
        this.packed = packed
        this.dependentBitfield = dependentBitfield
        this.nonType = nonType
        this.selectedOpaque = selectedOpaque
        this.visible = visible
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateOpacityHolder_TemplateOpacityHolder>()
        if (size != 32) {
            throw Exception("Size of TemplateOpacityHolder_TemplateOpacityHolder is not 32 but ${size} bytes")
        }
        let align = alignOf<TemplateOpacityHolder_TemplateOpacityHolder>()
        if (align != 4) {
            throw Exception("Alignment of TemplateOpacityHolder_TemplateOpacityHolder is not 4 but ${align} bytes")
        }
}
