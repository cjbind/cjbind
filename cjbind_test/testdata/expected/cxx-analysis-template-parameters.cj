package cjbind_ffi

@C
public struct UnusedParameter {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@C
public struct NestedTemplateUse {
    public let value: UInt8
    private init(value: UInt8) {
        this.value = value
    }
}

@C
public struct NestedTemplateIgnore_Inner {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@C
public struct NestedTemplateIgnore {
    public let value: UInt8
    private init(value: UInt8) {
        this.value = value
    }
}

public type AliasUse_Alias<T> = T

public type AliasOnly_Alias<T> = T

@C
public struct AliasOnly {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

public type TypedefAndAliasUse_First<T> = T

public type TypedefAndAliasUse_Second<U> = U

public type NestedAliasOnly_First<T> = T

public type NestedAliasOnly_Second<U> = U

@C
public struct NestedAliasOnly {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

public type DoublyIndirectUse_First<T> = T

public type DoublyIndirectUse_Second<U> = U

@C
public struct StaticOnlyUse {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@C
public struct BaseIgnoresParameter {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@C
public struct CrtpIgnoreWithIgnoringBase {
    public let _base: UInt8
    public var value: Int32
    private init(_base: UInt8, value: Int32) {
        this._base = _base
        this.value = value
    }
}

@C
public struct CrtpIndirectUse {
    public let _base: UInt8
    public var value: Int32
    private init(_base: UInt8, value: Int32) {
        this._base = _base
        this.value = value
    }
}

@C
public struct TemplateParameterAnalysisHolder {
    public let direct: DirectUse_open0_int_close0
    public let unused: UnusedParameter_open0_double_close0
    public let nested: NestedUse_open0_short_close0
    public let nestedTemplate: NestedTemplateUse_open0_unsigned_char_close0
    public let nestedTemplateIgnore: NestedTemplateIgnore_open0_unsigned_short_close0
    public let aliasUse: AliasUse_open0_long_long_close0
    public let aliasOnly: AliasOnly_open0_float_close0
    public let skipMiddle: SkipMiddleParameter_open0_int_bool_char_close0
    public let aliases: TypedefAndAliasUse_open0_unsigned_int_double_close0
    public let nestedAliasOnly: NestedAliasOnly_open0_long_float_close0
    public let doublyIndirect: DoublyIndirectUse_open0_long_float_bool_close0
    public let staticOnly: StaticOnlyUse_open0_double_close0
    public let crtpDirect: CrtpDirectUse_open0_short_close0
    public let crtpIgnoringBase: CrtpUseWithIgnoringBase_open0_unsigned_short_close0
    public let crtpIgnore: CrtpIgnoreWithIgnoringBase_open0_float_close0
    public let crtpIndirect: CrtpIndirectUse_open0_double_close0
    public let dependent: DependentOuter_open0_unsigned_long_long_close0
    private init(direct: DirectUse_open0_int_close0, unused: UnusedParameter_open0_double_close0,
        nested: NestedUse_open0_short_close0, nestedTemplate: NestedTemplateUse_open0_unsigned_char_close0,
        nestedTemplateIgnore: NestedTemplateIgnore_open0_unsigned_short_close0,
        aliasUse: AliasUse_open0_long_long_close0, aliasOnly: AliasOnly_open0_float_close0,
        skipMiddle: SkipMiddleParameter_open0_int_bool_char_close0,
        aliases: TypedefAndAliasUse_open0_unsigned_int_double_close0,
        nestedAliasOnly: NestedAliasOnly_open0_long_float_close0,
        doublyIndirect: DoublyIndirectUse_open0_long_float_bool_close0, staticOnly: StaticOnlyUse_open0_double_close0,
        crtpDirect: CrtpDirectUse_open0_short_close0,
        crtpIgnoringBase: CrtpUseWithIgnoringBase_open0_unsigned_short_close0,
        crtpIgnore: CrtpIgnoreWithIgnoringBase_open0_float_close0, crtpIndirect: CrtpIndirectUse_open0_double_close0,
        dependent: DependentOuter_open0_unsigned_long_long_close0) {
        this.direct = direct
        this.unused = unused
        this.nested = nested
        this.nestedTemplate = nestedTemplate
        this.nestedTemplateIgnore = nestedTemplateIgnore
        this.aliasUse = aliasUse
        this.aliasOnly = aliasOnly
        this.skipMiddle = skipMiddle
        this.aliases = aliases
        this.nestedAliasOnly = nestedAliasOnly
        this.doublyIndirect = doublyIndirect
        this.staticOnly = staticOnly
        this.crtpDirect = crtpDirect
        this.crtpIgnoringBase = crtpIgnoringBase
        this.crtpIgnore = crtpIgnore
        this.crtpIndirect = crtpIndirect
        this.dependent = dependent
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParameterAnalysisHolder>()
        if (size != 168) {
            throw Exception("Size of TemplateParameterAnalysisHolder is not 168 but ${size} bytes")
        }
        let align = alignOf<TemplateParameterAnalysisHolder>()
        if (align != 8) {
            throw Exception("Alignment of TemplateParameterAnalysisHolder is not 8 but ${align} bytes")
        }
}

@C
public struct TemplateParameterAnalysisHolder_NestedUse_Inner {
    public var value: Int16
    private init(value: Int16) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParameterAnalysisHolder_NestedUse_Inner>()
        if (size != 2) {
            throw Exception("Size of TemplateParameterAnalysisHolder_NestedUse_Inner is not 2 but ${size} bytes")
        }
        let align = alignOf<TemplateParameterAnalysisHolder_NestedUse_Inner>()
        if (align != 2) {
            throw Exception("Alignment of TemplateParameterAnalysisHolder_NestedUse_Inner is not 2 but ${align} bytes")
        }
}

@C
public struct Inner {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

public type TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner_First = Int64

public type TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner_Second = Float32

@C
public struct TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner {
    public var first: TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner_First
    public var second: TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner_Second
    private init(first: TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner_First,
        second: TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner_Second) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner>()
        if (size != 16) {
            throw Exception(
                "Size of TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner is not 16 but ${size} bytes")
        }
        let align = alignOf<TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner is not 8 but ${align} bytes")
        }
}

@C
public struct DependentLeaf_open0_unsigned_long_long_close0 {
    public var value: UInt64
    private init(value: UInt64) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentLeaf_open0_unsigned_long_long_close0>()
        if (size != 8) {
            throw Exception("Size of DependentLeaf_open0_unsigned_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<DependentLeaf_open0_unsigned_long_long_close0>()
        if (align != 8) {
            throw Exception("Alignment of DependentLeaf_open0_unsigned_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DependentMiddle_open0_unsigned_long_long_close0 {
    public let value: DependentLeaf_open0_unsigned_long_long_close0
    private init(value: DependentLeaf_open0_unsigned_long_long_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentMiddle_open0_unsigned_long_long_close0>()
        if (size != 8) {
            throw Exception("Size of DependentMiddle_open0_unsigned_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<DependentMiddle_open0_unsigned_long_long_close0>()
        if (align != 8) {
            throw Exception("Alignment of DependentMiddle_open0_unsigned_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DependentOuter_open0_unsigned_long_long_close0 {
    public let value: DependentMiddle_open0_unsigned_long_long_close0
    private init(value: DependentMiddle_open0_unsigned_long_long_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentOuter_open0_unsigned_long_long_close0>()
        if (size != 8) {
            throw Exception("Size of DependentOuter_open0_unsigned_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<DependentOuter_open0_unsigned_long_long_close0>()
        if (align != 8) {
            throw Exception("Alignment of DependentOuter_open0_unsigned_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct CrtpIndirectUse_open0_double_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpIndirectUse_open0_double_close0>()
        if (size != 16) {
            throw Exception("Size of CrtpIndirectUse_open0_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CrtpIndirectUse_open0_double_close0>()
        if (align != 8) {
            throw Exception("Alignment of CrtpIndirectUse_open0_double_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct CrtpIgnoreWithIgnoringBase_open0_float_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpIgnoreWithIgnoringBase_open0_float_close0>()
        if (size != 8) {
            throw Exception("Size of CrtpIgnoreWithIgnoringBase_open0_float_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<CrtpIgnoreWithIgnoringBase_open0_float_close0>()
        if (align != 4) {
            throw Exception("Alignment of CrtpIgnoreWithIgnoringBase_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct CrtpUseWithIgnoringBase_open0_unsigned_short_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpUseWithIgnoringBase_open0_unsigned_short_close0>()
        if (size != 8) {
            throw Exception("Size of CrtpUseWithIgnoringBase_open0_unsigned_short_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<CrtpUseWithIgnoringBase_open0_unsigned_short_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of CrtpUseWithIgnoringBase_open0_unsigned_short_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct CrtpDirectUse_open0_short_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpDirectUse_open0_short_close0>()
        if (size != 16) {
            throw Exception("Size of CrtpDirectUse_open0_short_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CrtpDirectUse_open0_short_close0>()
        if (align != 8) {
            throw Exception("Alignment of CrtpDirectUse_open0_short_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct StaticOnlyUse_open0_double_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<StaticOnlyUse_open0_double_close0>()
        if (size != 4) {
            throw Exception("Size of StaticOnlyUse_open0_double_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<StaticOnlyUse_open0_double_close0>()
        if (align != 4) {
            throw Exception("Alignment of StaticOnlyUse_open0_double_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct DoublyIndirectUse_open0_long_float_bool_close0 {
    public let value: TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner
    private init(value: TemplateParameterAnalysisHolder_DoublyIndirectUse_Inner) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoublyIndirectUse_open0_long_float_bool_close0>()
        if (size != 16) {
            throw Exception("Size of DoublyIndirectUse_open0_long_float_bool_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<DoublyIndirectUse_open0_long_float_bool_close0>()
        if (align != 8) {
            throw Exception("Alignment of DoublyIndirectUse_open0_long_float_bool_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct NestedAliasOnly_open0_long_float_close0 {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedAliasOnly_open0_long_float_close0>()
        if (size != 1) {
            throw Exception("Size of NestedAliasOnly_open0_long_float_close0 is not 1 but ${size} bytes")
        }
        let align = alignOf<NestedAliasOnly_open0_long_float_close0>()
        if (align != 1) {
            throw Exception("Alignment of NestedAliasOnly_open0_long_float_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct TypedefAndAliasUse_open0_unsigned_int_double_close0 {
    public var first: UInt32
    public var second: Float64
    private init(first: UInt32, second: Float64) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TypedefAndAliasUse_open0_unsigned_int_double_close0>()
        if (size != 16) {
            throw Exception("Size of TypedefAndAliasUse_open0_unsigned_int_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<TypedefAndAliasUse_open0_unsigned_int_double_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of TypedefAndAliasUse_open0_unsigned_int_double_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct SkipMiddleParameter_open0_int_bool_char_close0 {
    public var first: Int32
    public var third: UInt8
    private init(first: Int32, third: UInt8) {
        this.first = first
        this.third = third
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SkipMiddleParameter_open0_int_bool_char_close0>()
        if (size != 8) {
            throw Exception("Size of SkipMiddleParameter_open0_int_bool_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<SkipMiddleParameter_open0_int_bool_char_close0>()
        if (align != 4) {
            throw Exception("Alignment of SkipMiddleParameter_open0_int_bool_char_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasOnly_open0_float_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasOnly_open0_float_close0>()
        if (size != 4) {
            throw Exception("Size of AliasOnly_open0_float_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<AliasOnly_open0_float_close0>()
        if (align != 4) {
            throw Exception("Alignment of AliasOnly_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasUse_open0_long_long_close0 {
    public var value: Int64
    private init(value: Int64) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasUse_open0_long_long_close0>()
        if (size != 8) {
            throw Exception("Size of AliasUse_open0_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<AliasUse_open0_long_long_close0>()
        if (align != 8) {
            throw Exception("Alignment of AliasUse_open0_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Inner_open0_long_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Inner_open0_long_close0>()
        if (size != 4) {
            throw Exception("Size of Inner_open0_long_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Inner_open0_long_close0>()
        if (align != 4) {
            throw Exception("Alignment of Inner_open0_long_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct NestedTemplateIgnore_open0_unsigned_short_close0 {
    public let value: Inner_open0_long_close0
    private init(value: Inner_open0_long_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedTemplateIgnore_open0_unsigned_short_close0>()
        if (size != 4) {
            throw Exception("Size of NestedTemplateIgnore_open0_unsigned_short_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<NestedTemplateIgnore_open0_unsigned_short_close0>()
        if (align != 4) {
            throw Exception("Alignment of NestedTemplateIgnore_open0_unsigned_short_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct NestedTemplateUse_open0_unsigned_char_close0 {
    public let value: Inner_open0_long_close0
    private init(value: Inner_open0_long_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedTemplateUse_open0_unsigned_char_close0>()
        if (size != 16) {
            throw Exception("Size of NestedTemplateUse_open0_unsigned_char_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<NestedTemplateUse_open0_unsigned_char_close0>()
        if (align != 8) {
            throw Exception("Alignment of NestedTemplateUse_open0_unsigned_char_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct NestedUse_open0_short_close0 {
    public let inner: TemplateParameterAnalysisHolder_NestedUse_Inner
    private init(inner: TemplateParameterAnalysisHolder_NestedUse_Inner) {
        this.inner = inner
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedUse_open0_short_close0>()
        if (size != 2) {
            throw Exception("Size of NestedUse_open0_short_close0 is not 2 but ${size} bytes")
        }
        let align = alignOf<NestedUse_open0_short_close0>()
        if (align != 2) {
            throw Exception("Alignment of NestedUse_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct UnusedParameter_open0_double_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UnusedParameter_open0_double_close0>()
        if (size != 4) {
            throw Exception("Size of UnusedParameter_open0_double_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<UnusedParameter_open0_double_close0>()
        if (align != 4) {
            throw Exception("Alignment of UnusedParameter_open0_double_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct DirectUse_open0_int_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DirectUse_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of DirectUse_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<DirectUse_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of DirectUse_open0_int_close0 is not 4 but ${align} bytes")
        }
}
