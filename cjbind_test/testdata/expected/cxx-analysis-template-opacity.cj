package cjbind_ffi

@C
public struct TemplateOpacityHolder {
    public let packed: PackedTemplate_open0_int_close0
    public let dependentBitfield: UInt32
    public let nonType: VArray<UInt16, $5>
    public let selectedOpaque: UInt32
    public let visible: SelectiveOpaque_open0_float_close0
    public init(packed: PackedTemplate_open0_int_close0, dependentBitfield: UInt32, nonType: VArray<UInt16, $5>,
        selectedOpaque: UInt32, visible: SelectiveOpaque_open0_float_close0) {
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
        let size = sizeOf<TemplateOpacityHolder>()
        if (size != 32) {
            throw Exception("Size of TemplateOpacityHolder is not 32 but ${size} bytes")
        }
        let align = alignOf<TemplateOpacityHolder>()
        if (align != 4) {
            throw Exception("Alignment of TemplateOpacityHolder is not 4 but ${align} bytes")
        }
}

@C
public struct SelectiveOpaque_open0_float_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectiveOpaque_open0_float_close0>()
        if (size != 4) {
            throw Exception("Size of SelectiveOpaque_open0_float_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectiveOpaque_open0_float_close0>()
        if (align != 4) {
            throw Exception("Alignment of SelectiveOpaque_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct PackedTemplate_open0_int_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $5>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedTemplate_open0_int_close0>()
        if (size != 5) {
            throw Exception("Size of PackedTemplate_open0_int_close0 is not 5 but ${size} bytes")
        }
        let align = alignOf<PackedTemplate_open0_int_close0>()
        if (align != 1) {
            throw Exception("Alignment of PackedTemplate_open0_int_close0 is not 1 but ${align} bytes")
        }
}
