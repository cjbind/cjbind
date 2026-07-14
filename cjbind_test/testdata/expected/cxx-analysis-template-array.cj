package cjbind_ffi

public type AliasArrayOfParameter_Element_Element<T> = T

@C
public struct ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $4>
    public func clone(): ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0 {"
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
        let size = sizeOf<ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0>()
        if (size != 16) {
            throw Exception(
                "Size of ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public func clone(): AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0 {
        return this
    }
    public func toString(): String {
        var output = "AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0 {"
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
        let size = sizeOf<AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0>()
        if (size != 16) {
            throw Exception(
                "Size of AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0 is not 8 but ${align} bytes")
        }
}

public type AliasArrayOfParameter_open0_double_2_close0_Element_Element = Float64

@C
public struct ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0 {
    public let nested: ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0
    public func clone(): ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0 {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0>()
        if (size != 6) {
            throw Exception(
                "Size of ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0 is not 6 but ${size} bytes")
        }
        let align = alignOf<ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0 {
    let _cjbind_opaque_blob: VArray<UInt16, $3>
    public func clone(): ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0 {"
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
        let size = sizeOf<ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0>()
        if (size != 6) {
            throw Exception(
                "Size of ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0 is not 6 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    public func clone(): InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0 {
        return this
    }
    public func toString(): String {
        var output = "InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0>()
        if (size != 8) {
            throw Exception(
                "Size of InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_unsigned_char_2_close0_ArrayOfParameter_open0_unsigned_char_2_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $2>
    public func clone(): ArrayOfParameter_open0_unsigned_char_2_close0_ArrayOfParameter_open0_unsigned_char_2_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_unsigned_char_2_close0_ArrayOfParameter_open0_unsigned_char_2_close0 {"
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
        let size = sizeOf<ArrayOfParameter_open0_unsigned_char_2_close0_ArrayOfParameter_open0_unsigned_char_2_close0>()
        if (size != 2) {
            throw Exception(
                "Size of ArrayOfParameter_open0_unsigned_char_2_close0_ArrayOfParameter_open0_unsigned_char_2_close0 is not 2 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_unsigned_char_2_close0_ArrayOfParameter_open0_unsigned_char_2_close0>()
        if (align != 1) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_unsigned_char_2_close0_ArrayOfParameter_open0_unsigned_char_2_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0 {
    public let nested: ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0
    public func clone(): DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0 {
        return this
    }
    public func toString(): String {
        var output = "DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0 {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0>()
        if (size != 24) {
            throw Exception(
                "Size of DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0 {
    public let nested: ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0
    public func clone(): ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0 {
        return this
    }
    public func toString(): String {
        var output = "ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0 {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0>()
        if (size != 24) {
            throw Exception(
                "Size of ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of ContainsParameterArray_open0_long_long_close0_ContainsParameterArray_open0_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $3>
    public func clone(): ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $3>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0>()
        if (size != 24) {
            throw Exception(
                "Size of ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_long_long_3_close0_ArrayOfParameter_open0_long_long_3_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0 {
    public let nested: ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0
    public func clone(): FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0 {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0>()
        if (size != 12) {
            throw Exception(
                "Size of FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0 is not 12 but ${size} bytes")
        }
        let align = alignOf<FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $3>
    public func clone(): ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $3>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0>()
        if (size != 12) {
            throw Exception(
                "Size of ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0 is not 12 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_int_3_close0_ArrayOfParameter_open0_int_3_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0 {
    public let nested: ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0
    public func clone(): SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0 {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ArrayOfParameter_open0_short_3_close0_ArrayOfParameter_open0_short_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0>()
        if (size != 6) {
            throw Exception(
                "Size of SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0 is not 6 but ${size} bytes")
        }
        let align = alignOf<SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0 {
    public let nested: ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0
    public func clone(): ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0 {
        return this
    }
    public func toString(): String {
        var output = "ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0 {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0>()
        if (size != 24) {
            throw Exception(
                "Size of ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $6>
    public func clone(): ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0 {
        return this
    }
    public func toString(): String {
        var output = "ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $6>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0>()
        if (size != 24) {
            throw Exception(
                "Size of ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ArrayOfParameter_open0_unsigned_int_6_close0_ArrayOfParameter_open0_unsigned_int_6_close0 is not 4 but ${align} bytes")
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
    public let direct: ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0
    public let alias: AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0
    public let contained: ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0
    public let inherited: InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0
    public let deep: DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0
    public let firstOwner: FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0
    public let secondOwner: SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0
    public let parameterized: ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0
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
        output += ", firstOwner: "
        output += this.firstOwner.toString()
        output += ", secondOwner: "
        output += this.secondOwner.toString()
        output += ", parameterized: "
        output += this.parameterized.toString()
        output += ", fixedInteger: "
        output += this.fixedInteger.toString()
        output += ", pointerOnly: "
        output += this.pointerOnly.toString()
        output += ", scalarOnly: "
        output += this.scalarOnly.toString()
        output += " }"
        return output
    }
    public init(direct: ArrayOfParameter_open0_int_4_close0_ArrayOfParameter_open0_int_4_close0,
        alias: AliasArrayOfParameter_open0_double_2_close0_AliasArrayOfParameter_open0_double_2_close0,
        contained: ContainsParameterArray_open0_short_close0_ContainsParameterArray_open0_short_close0,
        inherited: InheritsParameterArray_open0_unsigned_char_close0_InheritsParameterArray_open0_unsigned_char_close0,
        deep: DeepParameterArray_open0_long_long_close0_DeepParameterArray_open0_long_long_close0,
        firstOwner: FirstParameterArrayOwner_open0_int_close0_FirstParameterArrayOwner_open0_int_close0,
        secondOwner: SecondParameterArrayOwner_open0_short_close0_SecondParameterArrayOwner_open0_short_close0,
        parameterized: ParameterArrayWrapper_open0_unsigned_int_6_close0_ParameterArrayWrapper_open0_unsigned_int_6_close0,
        fixedInteger: FixedIntegerArray_open0_5_close0_FixedIntegerArray_open0_5_close0,
        pointerOnly: PointerToParameter_open0_double_close0_PointerToParameter_open0_double_close0,
        scalarOnly: ScalarParameter_open0_float_close0_ScalarParameter_open0_float_close0) {
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
        let size = sizeOf<TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder>()
        if (size != 152) {
            throw Exception(
                "Size of TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder is not 152 but ${size} bytes")
        }
        let align = alignOf<TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateArrayAnalysisHolder_TemplateArrayAnalysisHolder is not 8 but ${align} bytes")
        }
}
