package cjbind_ffi

public type AliasArrayOfParameter_Element_Element<T> = T

@C
public struct ContainsParameterArray_ContainsParameterArray {
    public let nested: ArrayOfParameter_ArrayOfParameter
    public func clone(): ContainsParameterArray_ContainsParameterArray {
        return this
    }
    public func toString(): String {
        var output = "ContainsParameterArray_ContainsParameterArray {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ArrayOfParameter_ArrayOfParameter) {
        this.nested = nested
    }
}

@C
public struct InheritsParameterArray_InheritsParameterArray {
    public let marker: Int32
    public func clone(): InheritsParameterArray_InheritsParameterArray {
        return this
    }
    public func toString(): String {
        var output = "InheritsParameterArray_InheritsParameterArray {"
        output += " marker: "
        output += this.marker.toString()
        output += " }"
        return output
    }
    public init(marker: Int32) {
        this.marker = marker
    }
}

@C
public struct DeepParameterArray_DeepParameterArray {
    public let nested: ContainsParameterArray_ContainsParameterArray
    public func clone(): DeepParameterArray_DeepParameterArray {
        return this
    }
    public func toString(): String {
        var output = "DeepParameterArray_DeepParameterArray {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ContainsParameterArray_ContainsParameterArray) {
        this.nested = nested
    }
}

@C
public struct ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $4>
    public func clone(): ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0>()
        if (size != 16) {
            throw Exception(
                "Size of ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public func clone(): AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0 {
        return this
    }
    public func toString(): String {
        var output = "AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0 {"
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
        let size = sizeOf<AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0>()
        if (size != 16) {
            throw Exception(
                "Size of AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0 is not 8 but ${align} bytes")
        }
}

public type AliasArrayOfParameter_open0_2_close0_Element_Element = Float64

@C
public struct ArrayOfParameter_open0_3_close0_ArrayOfParameter_open0_3_close0 {
    let _cjbind_opaque_blob: VArray<UInt16, $3>
    public func clone(): ArrayOfParameter_open0_3_close0_ArrayOfParameter_open0_3_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_3_close0_ArrayOfParameter_open0_3_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $3>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_3_close0_ArrayOfParameter_open0_3_close0>()
        if (size != 6) {
            throw Exception(
                "Size of ArrayOfParameter_open0_3_close0_ArrayOfParameter_open0_3_close0 is not 6 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_3_close0_ArrayOfParameter_open0_3_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_3_close0_ArrayOfParameter_open0_3_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_2_close0_ArrayOfParameter_open0_2_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $2>
    public func clone(): ArrayOfParameter_open0_2_close0_ArrayOfParameter_open0_2_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_2_close0_ArrayOfParameter_open0_2_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_2_close0_ArrayOfParameter_open0_2_close0>()
        if (size != 2) {
            throw Exception(
                "Size of ArrayOfParameter_open0_2_close0_ArrayOfParameter_open0_2_close0 is not 2 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_2_close0_ArrayOfParameter_open0_2_close0>()
        if (align != 1) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_2_close0_ArrayOfParameter_open0_2_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $5>
    public func clone(): FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0 {
        return this
    }
    public func toString(): String {
        var output = "FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0>()
        if (size != 20) {
            throw Exception(
                "Size of FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0 is not 20 but ${size} bytes")
        }
        let align = alignOf<FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0 {
    public let values: CPointer<Float64>
    public func clone(): PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0 {
        return this
    }
    public func toString(): String {
        var output = "PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0 {"
        output += " values: "
        output += CPointer<Unit>(this.values).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(values: CPointer<Float64>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0>()
        if (size != 8) {
            throw Exception(
                "Size of PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0 {
    public let value: Float32
    public func clone(): ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0 {
        return this
    }
    public func toString(): String {
        var output = "ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0 {"
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
        let size = sizeOf<ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0>()
        if (size != 4) {
            throw Exception(
                "Size of ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder {
    public let direct: ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0
    public let alias: AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0
    public let contained: ContainsParameterArray_ContainsParameterArray
    public let inherited: InheritsParameterArray_InheritsParameterArray
    public let deep: DeepParameterArray_DeepParameterArray
    public let fixedInteger: FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0
    public let pointerOnly: PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0
    public let scalarOnly: ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0
    public func clone(): TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder {
        return this
    }
    public func toString(): String {
        var output = "TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder {"
        output += " direct: "
        output += this.direct.toString()
        output += ", alias: "
        output += this.alias.toString()
        output += ", contained: "
        output += this.contained.toString()
        output += ", inherited: "
        output += this.inherited.toString()
        output += ", deep: "
        output += this.deep.toString()
        output += ", fixedInteger: "
        output += this.fixedInteger.toString()
        output += ", pointerOnly: "
        output += this.pointerOnly.toString()
        output += ", scalarOnly: "
        output += this.scalarOnly.toString()
        output += " }"
        return output
    }
    public init(direct: ArrayOfParameter_open0_4_close0_ArrayOfParameter_open0_4_close0,
        alias: AliasArrayOfParameter_open0_2_close0_AliasArrayOfParameter_open0_2_close0,
        contained: ContainsParameterArray_ContainsParameterArray,
        inherited: InheritsParameterArray_InheritsParameterArray, deep: DeepParameterArray_DeepParameterArray,
        fixedInteger: FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0,
        pointerOnly: PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0,
        scalarOnly: ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0) {
        this.direct = direct
        this.alias = alias
        this.contained = contained
        this.inherited = inherited
        this.deep = deep
        this.fixedInteger = fixedInteger
        this.pointerOnly = pointerOnly
        this.scalarOnly = scalarOnly
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder>()
        if (size != 112) {
            throw Exception(
                "Size of TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder is not 112 but ${size} bytes")
        }
        let align = alignOf<TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder is not 8 but ${align} bytes")
        }
}
