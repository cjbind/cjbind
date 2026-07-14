package cjbind_ffi

public type AliasArrayOfParameter_Element<T> = T

@C
public struct ContainsParameterArray {
    public let nested: UInt8
    public init(nested: UInt8) {
        this.nested = nested
    }
}

@C
public struct InheritsParameterArray {
    public let marker: Int32
    public init(marker: Int32) {
        this.marker = marker
    }
}

@C
public struct DeepParameterArray {
    public let nested: ContainsParameterArray
    public init(nested: ContainsParameterArray) {
        this.nested = nested
    }
}

@C
public struct FirstParameterArrayOwner {
    public let nested: UInt8
    public init(nested: UInt8) {
        this.nested = nested
    }
}

@C
public struct SecondParameterArrayOwner {
    public let nested: UInt8
    public init(nested: UInt8) {
        this.nested = nested
    }
}

@C
public struct TemplateArrayAnalysisHolder {
    public let direct: VArray<UInt32, $4>
    public let alias: VArray<UInt64, $2>
    public let contained: ContainsParameterArray
    public let inherited: InheritsParameterArray
    public let deep: DeepParameterArray
    public let firstOwner: FirstParameterArrayOwner
    public let secondOwner: SecondParameterArrayOwner
    public let parameterized: VArray<UInt32, $6>
    public let fixedInteger: VArray<UInt32, $5>
    public let pointerOnly: PointerToParameter_open0_double_close0
    public let scalarOnly: ScalarParameter_open0_float_close0
    public init(direct: VArray<UInt32, $4>, alias: VArray<UInt64, $2>, contained: ContainsParameterArray,
        inherited: InheritsParameterArray, deep: DeepParameterArray, firstOwner: FirstParameterArrayOwner,
        secondOwner: SecondParameterArrayOwner, parameterized: VArray<UInt32, $6>, fixedInteger: VArray<UInt32, $5>,
        pointerOnly: PointerToParameter_open0_double_close0, scalarOnly: ScalarParameter_open0_float_close0) {
        this.direct = direct
        this.alias = alias
        this.contained = contained
        this.inherited = inherited
        this.deep = deep
        this.firstOwner = firstOwner
        this.secondOwner = secondOwner
        this.parameterized = parameterized
        this.fixedInteger = fixedInteger
        this.pointerOnly = pointerOnly
        this.scalarOnly = scalarOnly
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateArrayAnalysisHolder>()
        if (size != 152) {
            throw Exception("Size of TemplateArrayAnalysisHolder is not 152 but ${size} bytes")
        }
        let align = alignOf<TemplateArrayAnalysisHolder>()
        if (align != 8) {
            throw Exception("Alignment of TemplateArrayAnalysisHolder is not 8 but ${align} bytes")
        }
}

@C
public struct ScalarParameter_open0_float_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ScalarParameter_open0_float_close0>()
        if (size != 4) {
            throw Exception("Size of ScalarParameter_open0_float_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<ScalarParameter_open0_float_close0>()
        if (align != 4) {
            throw Exception("Alignment of ScalarParameter_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct PointerToParameter_open0_double_close0 {
    let _cjbind_opaque_blob: UInt64
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PointerToParameter_open0_double_close0>()
        if (size != 8) {
            throw Exception("Size of PointerToParameter_open0_double_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<PointerToParameter_open0_double_close0>()
        if (align != 8) {
            throw Exception("Alignment of PointerToParameter_open0_double_close0 is not 8 but ${align} bytes")
        }
}
