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
public struct TrivialValue {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TrivialValue>()
        if (size != 4) {
            throw Exception("Size of TrivialValue is not 4 but ${size} bytes")
        }
        let align = alignOf<TrivialValue>()
        if (align != 4) {
            throw Exception("Alignment of TrivialValue is not 4 but ${align} bytes")
        }
}

foreign func _ZN13OwnDestructorD1Ev(this_: CPointer<OwnDestructor>): Unit

public unsafe func OwnDestructor_OwnDestructor_destructor(this_: CPointer<OwnDestructor>): Unit {
    return _ZN13OwnDestructorD1Ev(this_)
}

@C
public struct OwnDestructor {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OwnDestructor>()
        if (size != 4) {
            throw Exception("Size of OwnDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<OwnDestructor>()
        if (align != 4) {
            throw Exception("Alignment of OwnDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct DeletedDestructor {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeletedDestructor>()
        if (size != 4) {
            throw Exception("Size of DeletedDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<DeletedDestructor>()
        if (align != 4) {
            throw Exception("Alignment of DeletedDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct ContainsDestructor {
    public let value: OwnDestructor
    public init(value: OwnDestructor) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsDestructor>()
        if (size != 4) {
            throw Exception("Size of ContainsDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<ContainsDestructor>()
        if (align != 4) {
            throw Exception("Alignment of ContainsDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct InheritsDestructor {
    public let _base: OwnDestructor
    public let marker: Int32
    public init(_base: OwnDestructor, marker: Int32) {
        this._base = _base
        this.marker = marker
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsDestructor>()
        if (size != 8) {
            throw Exception("Size of InheritsDestructor is not 8 but ${size} bytes")
        }
        let align = alignOf<InheritsDestructor>()
        if (align != 4) {
            throw Exception("Alignment of InheritsDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct DeepDestructor {
    public let value: ContainsDestructor
    public init(value: ContainsDestructor) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeepDestructor>()
        if (size != 4) {
            throw Exception("Size of DeepDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<DeepDestructor>()
        if (align != 4) {
            throw Exception("Alignment of DeepDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct PointerOnlyDestructor {
    public let value: CPointer<OwnDestructor>
    public init(value: CPointer<OwnDestructor>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PointerOnlyDestructor>()
        if (size != 8) {
            throw Exception("Size of PointerOnlyDestructor is not 8 but ${size} bytes")
        }
        let align = alignOf<PointerOnlyDestructor>()
        if (align != 8) {
            throw Exception("Alignment of PointerOnlyDestructor is not 8 but ${align} bytes")
        }
}

foreign func _ZN18UnionOwnDestructorD1Ev(this_: CPointer<UnionOwnDestructor>): Unit

public unsafe func UnionOwnDestructor_UnionOwnDestructor_destructor(this_: CPointer<UnionOwnDestructor>): Unit {
    return _ZN18UnionOwnDestructorD1Ev(this_)
}

@C
public struct UnionOwnDestructor {
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
        let size = sizeOf<UnionOwnDestructor>()
        if (size != 4) {
            throw Exception("Size of UnionOwnDestructor is not 4 but ${size} bytes")
        }
        let align = alignOf<UnionOwnDestructor>()
        if (align != 4) {
            throw Exception("Alignment of UnionOwnDestructor is not 4 but ${align} bytes")
        }
}

@C
public struct DestructorTemplateHolder {
    public let own: TemplateOwnDestructor_open0_int_close0
    public let propagated: TemplateField_open0_OwnDestructor_close0
    public let trivial: TemplateField_open0_TrivialValue_close0
    public init(own: TemplateOwnDestructor_open0_int_close0, propagated: TemplateField_open0_OwnDestructor_close0,
        trivial: TemplateField_open0_TrivialValue_close0) {
        this.own = own
        this.propagated = propagated
        this.trivial = trivial
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DestructorTemplateHolder>()
        if (size != 12) {
            throw Exception("Size of DestructorTemplateHolder is not 12 but ${size} bytes")
        }
        let align = alignOf<DestructorTemplateHolder>()
        if (align != 4) {
            throw Exception("Alignment of DestructorTemplateHolder is not 4 but ${align} bytes")
        }
}

@C
public struct IntegerOnly {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<IntegerOnly>()
        if (size != 4) {
            throw Exception("Size of IntegerOnly is not 4 but ${size} bytes")
        }
        let align = alignOf<IntegerOnly>()
        if (align != 4) {
            throw Exception("Alignment of IntegerOnly is not 4 but ${align} bytes")
        }
}

@C
public struct DirectFloat {
    public let value: Float32
    public init(value: Float32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DirectFloat>()
        if (size != 4) {
            throw Exception("Size of DirectFloat is not 4 but ${size} bytes")
        }
        let align = alignOf<DirectFloat>()
        if (align != 4) {
            throw Exception("Alignment of DirectFloat is not 4 but ${align} bytes")
        }
}

@C
public struct FloatArray {
    public let values: VArray<Float64, $3>
    public init(values: VArray<Float64, $3>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FloatArray>()
        if (size != 24) {
            throw Exception("Size of FloatArray is not 24 but ${size} bytes")
        }
        let align = alignOf<FloatArray>()
        if (align != 8) {
            throw Exception("Alignment of FloatArray is not 8 but ${align} bytes")
        }
}

@C
public struct ContainsFloat {
    public let value: DirectFloat
    public init(value: DirectFloat) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsFloat>()
        if (size != 4) {
            throw Exception("Size of ContainsFloat is not 4 but ${size} bytes")
        }
        let align = alignOf<ContainsFloat>()
        if (align != 4) {
            throw Exception("Alignment of ContainsFloat is not 4 but ${align} bytes")
        }
}

@C
public struct InheritsFloat {
    public let _base: DirectFloat
    public let marker: Int32
    public init(_base: DirectFloat, marker: Int32) {
        this._base = _base
        this.marker = marker
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsFloat>()
        if (size != 8) {
            throw Exception("Size of InheritsFloat is not 8 but ${size} bytes")
        }
        let align = alignOf<InheritsFloat>()
        if (align != 4) {
            throw Exception("Alignment of InheritsFloat is not 4 but ${align} bytes")
        }
}

public type FloatAlias = Float32

@C
public struct AliasedFloat {
    public let value: FloatAlias
    public init(value: FloatAlias) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasedFloat>()
        if (size != 4) {
            throw Exception("Size of AliasedFloat is not 4 but ${size} bytes")
        }
        let align = alignOf<AliasedFloat>()
        if (align != 4) {
            throw Exception("Alignment of AliasedFloat is not 4 but ${align} bytes")
        }
}

@C
public struct FloatPointerOnly {
    public let value: CPointer<Float32>
    public init(value: CPointer<Float32>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FloatPointerOnly>()
        if (size != 8) {
            throw Exception("Size of FloatPointerOnly is not 8 but ${size} bytes")
        }
        let align = alignOf<FloatPointerOnly>()
        if (align != 8) {
            throw Exception("Alignment of FloatPointerOnly is not 8 but ${align} bytes")
        }
}

@C
public struct FloatAnalysisHolder {
    public let integerOnly: IntegerOnly
    public let direct: DirectFloat
    public let array: FloatArray
    public let contained: ContainsFloat
    public let inherited: InheritsFloat
    public let aliased: AliasedFloat
    public let pointerOnly: FloatPointerOnly
    public let argumentFloat: TemplateArgumentFloat_open0_float_close0
    public let argumentInteger: TemplateArgumentFloat_open0_int_close0
    public let definitionFloat: TemplateDefinitionFloat_open0_int_close0
    public init(integerOnly: IntegerOnly, direct: DirectFloat, array: FloatArray, contained: ContainsFloat,
        inherited: InheritsFloat, aliased: AliasedFloat, pointerOnly: FloatPointerOnly,
        argumentFloat: TemplateArgumentFloat_open0_float_close0,
        argumentInteger: TemplateArgumentFloat_open0_int_close0,
        definitionFloat: TemplateDefinitionFloat_open0_int_close0) {
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
        let size = sizeOf<FloatAnalysisHolder>()
        if (size != 72) {
            throw Exception("Size of FloatAnalysisHolder is not 72 but ${size} bytes")
        }
        let align = alignOf<FloatAnalysisHolder>()
        if (align != 8) {
            throw Exception("Alignment of FloatAnalysisHolder is not 8 but ${align} bytes")
        }
}

@C
public struct TemplateDefinitionFloat_open0_int_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateDefinitionFloat_open0_int_close0>()
        if (size != 8) {
            throw Exception("Size of TemplateDefinitionFloat_open0_int_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateDefinitionFloat_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of TemplateDefinitionFloat_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateArgumentFloat_open0_int_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateArgumentFloat_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of TemplateArgumentFloat_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateArgumentFloat_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of TemplateArgumentFloat_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateArgumentFloat_open0_float_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateArgumentFloat_open0_float_close0>()
        if (size != 4) {
            throw Exception("Size of TemplateArgumentFloat_open0_float_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateArgumentFloat_open0_float_close0>()
        if (align != 4) {
            throw Exception("Alignment of TemplateArgumentFloat_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateField_open0_TrivialValue_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateField_open0_TrivialValue_close0>()
        if (size != 4) {
            throw Exception("Size of TemplateField_open0_TrivialValue_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateField_open0_TrivialValue_close0>()
        if (align != 4) {
            throw Exception("Alignment of TemplateField_open0_TrivialValue_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateField_open0_OwnDestructor_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateField_open0_OwnDestructor_close0>()
        if (size != 4) {
            throw Exception("Size of TemplateField_open0_OwnDestructor_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateField_open0_OwnDestructor_close0>()
        if (align != 4) {
            throw Exception("Alignment of TemplateField_open0_OwnDestructor_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateOwnDestructor_open0_int_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateOwnDestructor_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of TemplateOwnDestructor_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateOwnDestructor_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of TemplateOwnDestructor_open0_int_close0 is not 4 but ${align} bytes")
        }
}
