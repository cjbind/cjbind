package cjbind_ffi

func __cjbind_read_Int32_from_UInt32(storage: UInt32): Int32 {
    var s = storage
    return unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Int32_from_UInt32(storage: UInt32, val: Int32): UInt32 {
    var s = storage
    unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct TrivialValue_TrivialValue {
    public let value: Int32
    public func clone(): TrivialValue_TrivialValue {
        return this
    }
    public func toString(): String {
        var output = "TrivialValue_TrivialValue {"
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
        let size = sizeOf<TrivialValue_TrivialValue>()
        if (size != 4) {
            throw Exception("Size of TrivialValue_TrivialValue is not 4 but ${size} bytes")
        }
        let align = alignOf<TrivialValue_TrivialValue>()
        if (align != 4) {
            throw Exception("Alignment of TrivialValue_TrivialValue is not 4 but ${align} bytes")
        }
}

foreign func _ZN13OwnDestructorD1Ev(this_: CPointer<OwnDestructor_OwnDestructor>): Unit

public unsafe func OwnDestructor_OwnDestructor_destructor(this_: CPointer<OwnDestructor_OwnDestructor>): Unit {
    return _ZN13OwnDestructorD1Ev(this_)
}

@C
public struct OwnDestructor_OwnDestructor {
    public let value: Int32
    public func toString(): String {
        var output = "OwnDestructor_OwnDestructor {"
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
        let size = sizeOf<OwnDestructor_OwnDestructor>()
        if (size != 4) {
            throw Exception("Size of OwnDestructor_OwnDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<OwnDestructor_OwnDestructor>()
        if (align != 4) {
            throw Exception("Alignment of OwnDestructor_OwnDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct DeletedDestructor_DeletedDestructor {
    public let value: Int32
    public func toString(): String {
        var output = "DeletedDestructor_DeletedDestructor {"
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
        let size = sizeOf<DeletedDestructor_DeletedDestructor>()
        if (size != 4) {
            throw Exception("Size of DeletedDestructor_DeletedDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<DeletedDestructor_DeletedDestructor>()
        if (align != 4) {
            throw Exception("Alignment of DeletedDestructor_DeletedDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct ContainsDestructor_ContainsDestructor {
    public let value: OwnDestructor_OwnDestructor
    public func toString(): String {
        var output = "ContainsDestructor_ContainsDestructor {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: OwnDestructor_OwnDestructor) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsDestructor_ContainsDestructor>()
        if (size != 4) {
            throw Exception("Size of ContainsDestructor_ContainsDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<ContainsDestructor_ContainsDestructor>()
        if (align != 4) {
            throw Exception("Alignment of ContainsDestructor_ContainsDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct InheritsDestructor_InheritsDestructor {
    public let _base: OwnDestructor_OwnDestructor
    public let marker: Int32
    public func toString(): String {
        var output = "InheritsDestructor_InheritsDestructor {"
        output += " _base: "
        output += this._base.toString()
        output += ", marker: "
        output += this.marker.toString()
        output += " }"
        return output
    }
    public init(_base: OwnDestructor_OwnDestructor, marker: Int32) {
        this._base = _base
        this.marker = marker
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsDestructor_InheritsDestructor>()
        if (size != 8) {
            throw Exception("Size of InheritsDestructor_InheritsDestructor is not 8 but ${size} bytes")
        }
        let align = alignOf<InheritsDestructor_InheritsDestructor>()
        if (align != 4) {
            throw Exception("Alignment of InheritsDestructor_InheritsDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct DeepDestructor_DeepDestructor {
    public let value: ContainsDestructor_ContainsDestructor
    public func toString(): String {
        var output = "DeepDestructor_DeepDestructor {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: ContainsDestructor_ContainsDestructor) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeepDestructor_DeepDestructor>()
        if (size != 4) {
            throw Exception("Size of DeepDestructor_DeepDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<DeepDestructor_DeepDestructor>()
        if (align != 4) {
            throw Exception("Alignment of DeepDestructor_DeepDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct PointerOnlyDestructor_PointerOnlyDestructor {
    public let value: CPointer<OwnDestructor_OwnDestructor>
    public func clone(): PointerOnlyDestructor_PointerOnlyDestructor {
        return this
    }
    public func toString(): String {
        var output = "PointerOnlyDestructor_PointerOnlyDestructor {"
        output += " value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: CPointer<OwnDestructor_OwnDestructor>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PointerOnlyDestructor_PointerOnlyDestructor>()
        if (size != 8) {
            throw Exception("Size of PointerOnlyDestructor_PointerOnlyDestructor is not 8 but ${size} bytes")
        }
        let align = alignOf<PointerOnlyDestructor_PointerOnlyDestructor>()
        if (align != 8) {
            throw Exception("Alignment of PointerOnlyDestructor_PointerOnlyDestructor is not 8 but ${align} bytes")
        }
}

foreign func _ZN18UnionOwnDestructorD1Ev(this_: CPointer<UnionOwnDestructor_UnionOwnDestructor>): Unit

public unsafe func UnionOwnDestructor_UnionOwnDestructor_destructor(
    this_: CPointer<UnionOwnDestructor_UnionOwnDestructor>): Unit {
    return _ZN18UnionOwnDestructorD1Ev(this_)
}

@C
public struct UnionOwnDestructor_UnionOwnDestructor {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func value(): Int32 {
        return __cjbind_read_Int32_from_UInt32(this._storage)
    }
    public mut func value(val!: Int32): Unit {
        this._storage = __cjbind_write_Int32_from_UInt32(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UnionOwnDestructor_UnionOwnDestructor>()
        if (size != 4) {
            throw Exception("Size of UnionOwnDestructor_UnionOwnDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<UnionOwnDestructor_UnionOwnDestructor>()
        if (align != 4) {
            throw Exception("Alignment of UnionOwnDestructor_UnionOwnDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0 {
    public let value: Int32
    public func toString(): String {
        var output = "TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0 {"
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
        let size = sizeOf<TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0 {
    public let value: OwnDestructor_OwnDestructor
    public func toString(): String {
        var output = "TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: OwnDestructor_OwnDestructor) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0>()
        if (size != 4) {
            throw Exception(
                "Size of TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0 {
    public let value: TrivialValue_TrivialValue
    public func clone(): TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0 {
        return this
    }
    public func toString(): String {
        var output = "TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: TrivialValue_TrivialValue) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0>()
        if (size != 4) {
            throw Exception(
                "Size of TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct DestructorTemplateHolder_DestructorTemplateHolder {
    public let own: TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0
    public let propagated: TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0
    public let trivial: TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0
    public func toString(): String {
        var output = "DestructorTemplateHolder_DestructorTemplateHolder {"
        output += " own: "
        output += this.own.toString()
        output += ", propagated: "
        output += this.propagated.toString()
        output += ", trivial: "
        output += this.trivial.toString()
        output += " }"
        return output
    }
    public init(own: TemplateOwnDestructor_open0_int_close0_TemplateOwnDestructor_open0_int_close0,
        propagated: TemplateField_open0_OwnDestructor_close0_TemplateField_open0_OwnDestructor_close0,
        trivial: TemplateField_open0_TrivialValue_close0_TemplateField_open0_TrivialValue_close0) {
        this.own = own
        this.propagated = propagated
        this.trivial = trivial
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DestructorTemplateHolder_DestructorTemplateHolder>()
        if (size != 12) {
            throw Exception("Size of DestructorTemplateHolder_DestructorTemplateHolder is not 12 but ${size} bytes")
        }
        let align = alignOf<DestructorTemplateHolder_DestructorTemplateHolder>()
        if (align != 4) {
            throw Exception(
                "Alignment of DestructorTemplateHolder_DestructorTemplateHolder is not 4 but ${align} bytes")
        }
}

@C
public struct IntegerOnly_IntegerOnly {
    public let value: Int32
    public func clone(): IntegerOnly_IntegerOnly {
        return this
    }
    public func toString(): String {
        var output = "IntegerOnly_IntegerOnly {"
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
        let size = sizeOf<IntegerOnly_IntegerOnly>()
        if (size != 4) {
            throw Exception("Size of IntegerOnly_IntegerOnly is not 4 but ${size} bytes")
        }
        let align = alignOf<IntegerOnly_IntegerOnly>()
        if (align != 4) {
            throw Exception("Alignment of IntegerOnly_IntegerOnly is not 4 but ${align} bytes")
        }
}

@C
public struct DirectFloat_DirectFloat {
    public let value: Float32
    public func clone(): DirectFloat_DirectFloat {
        return this
    }
    public func toString(): String {
        var output = "DirectFloat_DirectFloat {"
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
        let size = sizeOf<DirectFloat_DirectFloat>()
        if (size != 4) {
            throw Exception("Size of DirectFloat_DirectFloat is not 4 but ${size} bytes")
        }
        let align = alignOf<DirectFloat_DirectFloat>()
        if (align != 4) {
            throw Exception("Alignment of DirectFloat_DirectFloat is not 4 but ${align} bytes")
        }
}

@C
public struct FloatArray_FloatArray {
    public let values: VArray<Float64, $3>
    public func clone(): FloatArray_FloatArray {
        return this
    }
    public func toString(): String {
        var output = "FloatArray_FloatArray {"
        output += " values: "
        output += "["
        for (__cjbindDebugIndex0 in 0..3) {
            if (__cjbindDebugIndex0 != 0) {
                output += ", "
            }
            output += this.values[__cjbindDebugIndex0].toString()
        }
        output += "]"
        output += " }"
        return output
    }
    public init(values: VArray<Float64, $3>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FloatArray_FloatArray>()
        if (size != 24) {
            throw Exception("Size of FloatArray_FloatArray is not 24 but ${size} bytes")
        }
        let align = alignOf<FloatArray_FloatArray>()
        if (align != 8) {
            throw Exception("Alignment of FloatArray_FloatArray is not 8 but ${align} bytes")
        }
}

@C
public struct ContainsFloat_ContainsFloat {
    public let value: DirectFloat_DirectFloat
    public func clone(): ContainsFloat_ContainsFloat {
        return this
    }
    public func toString(): String {
        var output = "ContainsFloat_ContainsFloat {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DirectFloat_DirectFloat) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsFloat_ContainsFloat>()
        if (size != 4) {
            throw Exception("Size of ContainsFloat_ContainsFloat is not 4 but ${size} bytes")
        }
        let align = alignOf<ContainsFloat_ContainsFloat>()
        if (align != 4) {
            throw Exception("Alignment of ContainsFloat_ContainsFloat is not 4 but ${align} bytes")
        }
}

@C
public struct InheritsFloat_InheritsFloat {
    public let _base: DirectFloat_DirectFloat
    public let marker: Int32
    public func clone(): InheritsFloat_InheritsFloat {
        return this
    }
    public func toString(): String {
        var output = "InheritsFloat_InheritsFloat {"
        output += " _base: "
        output += this._base.toString()
        output += ", marker: "
        output += this.marker.toString()
        output += " }"
        return output
    }
    public init(_base: DirectFloat_DirectFloat, marker: Int32) {
        this._base = _base
        this.marker = marker
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsFloat_InheritsFloat>()
        if (size != 8) {
            throw Exception("Size of InheritsFloat_InheritsFloat is not 8 but ${size} bytes")
        }
        let align = alignOf<InheritsFloat_InheritsFloat>()
        if (align != 4) {
            throw Exception("Alignment of InheritsFloat_InheritsFloat is not 4 but ${align} bytes")
        }
}

public type FloatAlias_FloatAlias = Float32

@C
public struct AliasedFloat_AliasedFloat {
    public let value: FloatAlias_FloatAlias
    public func clone(): AliasedFloat_AliasedFloat {
        return this
    }
    public func toString(): String {
        var output = "AliasedFloat_AliasedFloat {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: FloatAlias_FloatAlias) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasedFloat_AliasedFloat>()
        if (size != 4) {
            throw Exception("Size of AliasedFloat_AliasedFloat is not 4 but ${size} bytes")
        }
        let align = alignOf<AliasedFloat_AliasedFloat>()
        if (align != 4) {
            throw Exception("Alignment of AliasedFloat_AliasedFloat is not 4 but ${align} bytes")
        }
}

@C
public struct FloatPointerOnly_FloatPointerOnly {
    public let value: CPointer<Float32>
    public func clone(): FloatPointerOnly_FloatPointerOnly {
        return this
    }
    public func toString(): String {
        var output = "FloatPointerOnly_FloatPointerOnly {"
        output += " value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: CPointer<Float32>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FloatPointerOnly_FloatPointerOnly>()
        if (size != 8) {
            throw Exception("Size of FloatPointerOnly_FloatPointerOnly is not 8 but ${size} bytes")
        }
        let align = alignOf<FloatPointerOnly_FloatPointerOnly>()
        if (align != 8) {
            throw Exception("Alignment of FloatPointerOnly_FloatPointerOnly is not 8 but ${align} bytes")
        }
}

@C
public struct TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0 {
    public let value: Float32
    public func clone(): TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0 {
        return this
    }
    public func toString(): String {
        var output = "TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0 {"
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
        let size = sizeOf<TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0>()
        if (size != 4) {
            throw Exception(
                "Size of TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0 {
    public let value: Int32
    public func clone(): TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0 {"
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
        let size = sizeOf<TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0 {
    public let value: Int32
    public let fixed: Float32
    public func clone(): TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += ", fixed: "
        output += this.fixed.toString()
        output += " }"
        return output
    }
    public init(value: Int32, fixed: Float32) {
        this.value = value
        this.fixed = fixed
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0>()
        if (size != 8) {
            throw Exception(
                "Size of TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct FloatAnalysisHolder_FloatAnalysisHolder {
    public let integerOnly: IntegerOnly_IntegerOnly
    public let direct: DirectFloat_DirectFloat
    public let array: FloatArray_FloatArray
    public let contained: ContainsFloat_ContainsFloat
    public let inherited: InheritsFloat_InheritsFloat
    public let aliased: AliasedFloat_AliasedFloat
    public let pointerOnly: FloatPointerOnly_FloatPointerOnly
    public let argumentFloat: TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0
    public let argumentInteger: TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0
    public let definitionFloat: TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0
    public func clone(): FloatAnalysisHolder_FloatAnalysisHolder {
        return this
    }
    public func toString(): String {
        var output = "FloatAnalysisHolder_FloatAnalysisHolder {"
        output += " integerOnly: "
        output += this.integerOnly.toString()
        output += ", direct: "
        output += this.direct.toString()
        output += ", array: "
        output += this.array.toString()
        output += ", contained: "
        output += this.contained.toString()
        output += ", inherited: "
        output += this.inherited.toString()
        output += ", aliased: "
        output += this.aliased.toString()
        output += ", pointerOnly: "
        output += this.pointerOnly.toString()
        output += ", argumentFloat: "
        output += this.argumentFloat.toString()
        output += ", argumentInteger: "
        output += this.argumentInteger.toString()
        output += ", definitionFloat: "
        output += this.definitionFloat.toString()
        output += " }"
        return output
    }
    public init(integerOnly: IntegerOnly_IntegerOnly, direct: DirectFloat_DirectFloat, array: FloatArray_FloatArray,
        contained: ContainsFloat_ContainsFloat, inherited: InheritsFloat_InheritsFloat,
        aliased: AliasedFloat_AliasedFloat, pointerOnly: FloatPointerOnly_FloatPointerOnly,
        argumentFloat: TemplateArgumentFloat_open0_float_close0_TemplateArgumentFloat_open0_float_close0,
        argumentInteger: TemplateArgumentFloat_open0_int_close0_TemplateArgumentFloat_open0_int_close0,
        definitionFloat: TemplateDefinitionFloat_open0_int_close0_TemplateDefinitionFloat_open0_int_close0) {
        this.integerOnly = integerOnly
        this.direct = direct
        this.array = array
        this.contained = contained
        this.inherited = inherited
        this.aliased = aliased
        this.pointerOnly = pointerOnly
        this.argumentFloat = argumentFloat
        this.argumentInteger = argumentInteger
        this.definitionFloat = definitionFloat
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FloatAnalysisHolder_FloatAnalysisHolder>()
        if (size != 72) {
            throw Exception("Size of FloatAnalysisHolder_FloatAnalysisHolder is not 72 but ${size} bytes")
        }
        let align = alignOf<FloatAnalysisHolder_FloatAnalysisHolder>()
        if (align != 8) {
            throw Exception("Alignment of FloatAnalysisHolder_FloatAnalysisHolder is not 8 but ${align} bytes")
        }
}
