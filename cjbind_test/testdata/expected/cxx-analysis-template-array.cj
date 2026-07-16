package cjbind_ffi

public type AliasArrayOfParameter_Element<T> = T

@C
public struct ContainsParameterArray {
    public let nested: UInt8
    private init(nested: UInt8) {
        this.nested = nested
    }
}

@C
public struct InheritsParameterArray {
    public var marker: Int32
    private init(marker: Int32) {
        this.marker = marker
    }
}

@C
public struct DeepParameterArray {
    public let nested: UInt8
    private init(nested: UInt8) {
        this.nested = nested
    }
}

@C
public struct FirstParameterArrayOwner {
    public let nested: UInt8
    private init(nested: UInt8) {
        this.nested = nested
    }
}

@C
public struct SecondParameterArrayOwner {
    public let nested: UInt8
    private init(nested: UInt8) {
        this.nested = nested
    }
}

@C
public struct TemplateArrayAnalysisHolder {
    public let direct: ArrayOfParameter_open0_int_4_close0
    public let alias: AliasArrayOfParameter_open0_double_2_close0
    public let aliasFloat: AliasArrayOfParameter_open0_float_2_close0
    public let contained: ContainsParameterArray_open0_short_close0
    public let inherited: InheritsParameterArray_open0_unsigned_char_close0
    public let deep: DeepParameterArray_open0_long_long_close0
    public let firstOwner: FirstParameterArrayOwner_open0_int_close0
    public let secondOwner: SecondParameterArrayOwner_open0_short_close0
    public let parameterized: ParameterArrayWrapper_open0_unsigned_int_6_close0
    public let fixedInteger: FixedIntegerArray_open0_float_5_close0
    public let pointerOnly: PointerToParameter_open0_double_close0
    public let scalarOnly: ScalarParameter_open0_float_close0
    public let pointerArgument: VArray<UInt8, $5>
    public let nullPointerArgument: VArray<UInt8, $3>
    private init(direct: ArrayOfParameter_open0_int_4_close0, alias: AliasArrayOfParameter_open0_double_2_close0,
        aliasFloat: AliasArrayOfParameter_open0_float_2_close0, contained: ContainsParameterArray_open0_short_close0,
        inherited: InheritsParameterArray_open0_unsigned_char_close0, deep: DeepParameterArray_open0_long_long_close0,
        firstOwner: FirstParameterArrayOwner_open0_int_close0,
        secondOwner: SecondParameterArrayOwner_open0_short_close0,
        parameterized: ParameterArrayWrapper_open0_unsigned_int_6_close0,
        fixedInteger: FixedIntegerArray_open0_float_5_close0, pointerOnly: PointerToParameter_open0_double_close0,
        scalarOnly: ScalarParameter_open0_float_close0, pointerArgument: VArray<UInt8, $5>,
        nullPointerArgument: VArray<UInt8, $3>) {
        this.direct = direct
        this.alias = alias
        this.aliasFloat = aliasFloat
        this.contained = contained
        this.inherited = inherited
        this.deep = deep
        this.firstOwner = firstOwner
        this.secondOwner = secondOwner
        this.parameterized = parameterized
        this.fixedInteger = fixedInteger
        this.pointerOnly = pointerOnly
        this.scalarOnly = scalarOnly
        this.pointerArgument = pointerArgument
        this.nullPointerArgument = nullPointerArgument
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateArrayAnalysisHolder>()
        if (size != 168) {
            throw Exception("Size of TemplateArrayAnalysisHolder is not 168 but ${size} bytes")
        }
        let align = alignOf<TemplateArrayAnalysisHolder>()
        if (align != 8) {
            throw Exception("Alignment of TemplateArrayAnalysisHolder is not 8 but ${align} bytes")
        }
}

@C
public struct ScalarParameter_open0_float_close0 {
    public var value: Float32
    private init(value: Float32) {
        this.value = value
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
    public var values: CPointer<Float64>
    private init(values: CPointer<Float64>) {
        this.values = values
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

@C
public struct FixedIntegerArray_open0_float_5_close0 {
    public let values: VArray<Int32, $5>
    private init(values: VArray<Int32, $5>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FixedIntegerArray_open0_float_5_close0>()
        if (size != 20) {
            throw Exception("Size of FixedIntegerArray_open0_float_5_close0 is not 20 but ${size} bytes")
        }
        let align = alignOf<FixedIntegerArray_open0_float_5_close0>()
        if (align != 4) {
            throw Exception("Alignment of FixedIntegerArray_open0_float_5_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_unsigned_int_6_close0 {
    public let values: VArray<UInt32, $6>
    private init(values: VArray<UInt32, $6>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_unsigned_int_6_close0>()
        if (size != 24) {
            throw Exception("Size of ArrayOfParameter_open0_unsigned_int_6_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_unsigned_int_6_close0>()
        if (align != 4) {
            throw Exception("Alignment of ArrayOfParameter_open0_unsigned_int_6_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ParameterArrayWrapper_open0_unsigned_int_6_close0 {
    public let nested: ArrayOfParameter_open0_unsigned_int_6_close0
    private init(nested: ArrayOfParameter_open0_unsigned_int_6_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ParameterArrayWrapper_open0_unsigned_int_6_close0>()
        if (size != 24) {
            throw Exception("Size of ParameterArrayWrapper_open0_unsigned_int_6_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ParameterArrayWrapper_open0_unsigned_int_6_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ParameterArrayWrapper_open0_unsigned_int_6_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_short_3_close0 {
    public let values: VArray<Int16, $3>
    private init(values: VArray<Int16, $3>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_short_3_close0>()
        if (size != 6) {
            throw Exception("Size of ArrayOfParameter_open0_short_3_close0 is not 6 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_short_3_close0>()
        if (align != 2) {
            throw Exception("Alignment of ArrayOfParameter_open0_short_3_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct SecondParameterArrayOwner_open0_short_close0 {
    public let nested: ArrayOfParameter_open0_short_3_close0
    private init(nested: ArrayOfParameter_open0_short_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SecondParameterArrayOwner_open0_short_close0>()
        if (size != 6) {
            throw Exception("Size of SecondParameterArrayOwner_open0_short_close0 is not 6 but ${size} bytes")
        }
        let align = alignOf<SecondParameterArrayOwner_open0_short_close0>()
        if (align != 2) {
            throw Exception("Alignment of SecondParameterArrayOwner_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_int_3_close0 {
    public let values: VArray<Int32, $3>
    private init(values: VArray<Int32, $3>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_int_3_close0>()
        if (size != 12) {
            throw Exception("Size of ArrayOfParameter_open0_int_3_close0 is not 12 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_int_3_close0>()
        if (align != 4) {
            throw Exception("Alignment of ArrayOfParameter_open0_int_3_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct FirstParameterArrayOwner_open0_int_close0 {
    public let nested: ArrayOfParameter_open0_int_3_close0
    private init(nested: ArrayOfParameter_open0_int_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FirstParameterArrayOwner_open0_int_close0>()
        if (size != 12) {
            throw Exception("Size of FirstParameterArrayOwner_open0_int_close0 is not 12 but ${size} bytes")
        }
        let align = alignOf<FirstParameterArrayOwner_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of FirstParameterArrayOwner_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_long_long_3_close0 {
    public let values: VArray<Int64, $3>
    private init(values: VArray<Int64, $3>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_long_long_3_close0>()
        if (size != 24) {
            throw Exception("Size of ArrayOfParameter_open0_long_long_3_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_long_long_3_close0>()
        if (align != 8) {
            throw Exception("Alignment of ArrayOfParameter_open0_long_long_3_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct ContainsParameterArray_open0_long_long_close0 {
    public let nested: ArrayOfParameter_open0_long_long_3_close0
    private init(nested: ArrayOfParameter_open0_long_long_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsParameterArray_open0_long_long_close0>()
        if (size != 24) {
            throw Exception("Size of ContainsParameterArray_open0_long_long_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<ContainsParameterArray_open0_long_long_close0>()
        if (align != 8) {
            throw Exception("Alignment of ContainsParameterArray_open0_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DeepParameterArray_open0_long_long_close0 {
    public let nested: ContainsParameterArray_open0_long_long_close0
    private init(nested: ContainsParameterArray_open0_long_long_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeepParameterArray_open0_long_long_close0>()
        if (size != 24) {
            throw Exception("Size of DeepParameterArray_open0_long_long_close0 is not 24 but ${size} bytes")
        }
        let align = alignOf<DeepParameterArray_open0_long_long_close0>()
        if (align != 8) {
            throw Exception("Alignment of DeepParameterArray_open0_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct InheritsParameterArray_open0_unsigned_char_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsParameterArray_open0_unsigned_char_close0>()
        if (size != 8) {
            throw Exception("Size of InheritsParameterArray_open0_unsigned_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<InheritsParameterArray_open0_unsigned_char_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of InheritsParameterArray_open0_unsigned_char_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ContainsParameterArray_open0_short_close0 {
    public let nested: ArrayOfParameter_open0_short_3_close0
    private init(nested: ArrayOfParameter_open0_short_3_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsParameterArray_open0_short_close0>()
        if (size != 6) {
            throw Exception("Size of ContainsParameterArray_open0_short_close0 is not 6 but ${size} bytes")
        }
        let align = alignOf<ContainsParameterArray_open0_short_close0>()
        if (align != 2) {
            throw Exception("Alignment of ContainsParameterArray_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct AliasArrayOfParameter_open0_float_2_close0 {
    public let values: VArray<Float32, $2>
    private init(values: VArray<Float32, $2>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasArrayOfParameter_open0_float_2_close0>()
        if (size != 8) {
            throw Exception("Size of AliasArrayOfParameter_open0_float_2_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<AliasArrayOfParameter_open0_float_2_close0>()
        if (align != 4) {
            throw Exception("Alignment of AliasArrayOfParameter_open0_float_2_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasArrayOfParameter_open0_double_2_close0 {
    public let values: VArray<Float64, $2>
    private init(values: VArray<Float64, $2>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasArrayOfParameter_open0_double_2_close0>()
        if (size != 16) {
            throw Exception("Size of AliasArrayOfParameter_open0_double_2_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<AliasArrayOfParameter_open0_double_2_close0>()
        if (align != 8) {
            throw Exception("Alignment of AliasArrayOfParameter_open0_double_2_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct ArrayOfParameter_open0_int_4_close0 {
    public let values: VArray<Int32, $4>
    private init(values: VArray<Int32, $4>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ArrayOfParameter_open0_int_4_close0>()
        if (size != 16) {
            throw Exception("Size of ArrayOfParameter_open0_int_4_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<ArrayOfParameter_open0_int_4_close0>()
        if (align != 4) {
            throw Exception("Alignment of ArrayOfParameter_open0_int_4_close0 is not 4 but ${align} bytes")
        }
}
