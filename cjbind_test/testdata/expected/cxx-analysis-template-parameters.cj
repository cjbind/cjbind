package cjbind_ffi

@C
public struct UnusedParameter {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct NestedTemplateIgnore_Inner {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct NestedTemplateIgnore {
    public let value: NestedTemplateIgnore_Inner
    public init(value: NestedTemplateIgnore_Inner) {
        this.value = value
    }
}

public type AliasUse_Alias<T> = T

public type AliasOnly_Alias<T> = T

@C
public struct AliasOnly {
    public let value: Int32
    public init(value: Int32) {
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
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

public type DoublyIndirectUse_First<T> = T

public type DoublyIndirectUse_Second<U> = U

@C
public struct StaticOnlyUse {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct BaseIgnoresParameter {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct CrtpIgnoreWithIgnoringBase {
    public let _base: BaseIgnoresParameter
    public let value: Int32
    public init(_base: BaseIgnoresParameter, value: Int32) {
        this._base = _base
        this.value = value
    }
}

@C
public struct CrtpIndirectUse {
    public let _base: UInt8
    public let value: Int32
    public init(_base: UInt8, value: Int32) {
        this._base = _base
        this.value = value
    }
}

@C
public struct TemplateParameterAnalysisHolder {
    public let direct: DirectUse_open0_int_close0
    public let unused: UnusedParameter
    public let nested: UInt16
    public let nestedTemplate: VArray<UInt64, $2>
    public let nestedTemplateIgnore: NestedTemplateIgnore
    public let aliasUse: AliasUse_open0_long_long_close0
    public let aliasOnly: AliasOnly
    public let skipMiddle: SkipMiddleParameter_open0_int_char_close0
    public let aliases: TypedefAndAliasUse_open0_unsigned_int_double_close0
    public let nestedAliasOnly: NestedAliasOnly
    public let doublyIndirect: VArray<UInt64, $2>
    public let staticOnly: StaticOnlyUse
    public let crtpDirect: VArray<UInt64, $2>
    public let crtpIgnoringBase: CrtpUseWithIgnoringBase_open0_unsigned_short_close0
    public let crtpIgnore: CrtpIgnoreWithIgnoringBase
    public let crtpIndirect: CrtpIndirectUse
    public let dependent: UInt64
    public init(direct: DirectUse_open0_int_close0, unused: UnusedParameter, nested: UInt16,
        nestedTemplate: VArray<UInt64, $2>, nestedTemplateIgnore: NestedTemplateIgnore,
        aliasUse: AliasUse_open0_long_long_close0, aliasOnly: AliasOnly,
        skipMiddle: SkipMiddleParameter_open0_int_char_close0,
        aliases: TypedefAndAliasUse_open0_unsigned_int_double_close0, nestedAliasOnly: NestedAliasOnly,
        doublyIndirect: VArray<UInt64, $2>, staticOnly: StaticOnlyUse, crtpDirect: VArray<UInt64, $2>,
        crtpIgnoringBase: CrtpUseWithIgnoringBase_open0_unsigned_short_close0, crtpIgnore: CrtpIgnoreWithIgnoringBase,
        crtpIndirect: CrtpIndirectUse, dependent: UInt64) {
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
public struct CrtpUseWithIgnoringBase_open0_unsigned_short_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    public init() {
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
public struct TypedefAndAliasUse_open0_unsigned_int_double_close0 {
    public let first: UInt32
    public let second: Float64
    public init(first: UInt32, second: Float64) {
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
public struct SkipMiddleParameter_open0_int_char_close0 {
    public let first: Int32
    public let third: UInt8
    public init(first: Int32, third: UInt8) {
        this.first = first
        this.third = third
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SkipMiddleParameter_open0_int_char_close0>()
        if (size != 8) {
            throw Exception("Size of SkipMiddleParameter_open0_int_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<SkipMiddleParameter_open0_int_char_close0>()
        if (align != 4) {
            throw Exception("Alignment of SkipMiddleParameter_open0_int_char_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasUse_open0_long_long_close0 {
    public let value: Int64
    public init(value: Int64) {
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
public struct DirectUse_open0_int_close0 {
    public let value: Int32
    public init(value: Int32) {
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
