package cjbind_ffi

@C
public struct UnusedParameter_UnusedParameter {
    public let value: Int32
    public func clone(): UnusedParameter_UnusedParameter {
        return this
    }
    public func toString(): String {
        var output = "UnusedParameter_UnusedParameter {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct NestedTemplateIgnore_NestedTemplateIgnore {
    public let value: NestedTemplateIgnore_Inner_Inner
    public func clone(): NestedTemplateIgnore_NestedTemplateIgnore {
        return this
    }
    public func toString(): String {
        var output = "NestedTemplateIgnore_NestedTemplateIgnore {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: NestedTemplateIgnore_Inner_Inner) {
        this.value = value
    }
}

public type AliasUse_Alias_Alias<T> = T

public type AliasOnly_Alias_Alias<T> = T

@C
public struct AliasOnly_AliasOnly {
    public let value: Int32
    public func clone(): AliasOnly_AliasOnly {
        return this
    }
    public func toString(): String {
        var output = "AliasOnly_AliasOnly {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

public type TypedefAndAliasUse_First_First<T> = T

public type TypedefAndAliasUse_Second_Second<U> = U

public type NestedAliasOnly_First_First<T> = T

public type NestedAliasOnly_Second_Second<U> = U

@C
public struct NestedAliasOnly_NestedAliasOnly {
    let _cjbind_empty: UInt8
    public func clone(): NestedAliasOnly_NestedAliasOnly {
        return this
    }
    public func toString(): String {
        var output = "NestedAliasOnly_NestedAliasOnly {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

public type DoublyIndirectUse_First_First<T> = T

public type DoublyIndirectUse_Second_Second<U> = U

@C
public struct StaticOnlyUse_StaticOnlyUse {
    public let value: Int32
    public func clone(): StaticOnlyUse_StaticOnlyUse {
        return this
    }
    public func toString(): String {
        var output = "StaticOnlyUse_StaticOnlyUse {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct BaseIgnoresParameter_BaseIgnoresParameter {
    public let value: Int32
    public func clone(): BaseIgnoresParameter_BaseIgnoresParameter {
        return this
    }
    public func toString(): String {
        var output = "BaseIgnoresParameter_BaseIgnoresParameter {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct CrtpIgnoreWithIgnoringBase_CrtpIgnoreWithIgnoringBase {
    public let _base: BaseIgnoresParameter_BaseIgnoresParameter
    public let value: Int32
    public func clone(): CrtpIgnoreWithIgnoringBase_CrtpIgnoreWithIgnoringBase {
        return this
    }
    public func toString(): String {
        var output = "CrtpIgnoreWithIgnoringBase_CrtpIgnoreWithIgnoringBase {"
        output += " _base: "
        output += this._base.toString()
        output += ", value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(_base: BaseIgnoresParameter_BaseIgnoresParameter, value: Int32) {
        this._base = _base
        this.value = value
    }
}

@C
public struct DependentMiddle_open0_T_close0_DependentMiddle_open0_T_close0 {
    public let value: Int32
    public func clone(): DependentMiddle_open0_T_close0_DependentMiddle_open0_T_close0 {
        return this
    }
    public func toString(): String {
        var output = "DependentMiddle_open0_T_close0_DependentMiddle_open0_T_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct DependentOuter_DependentOuter {
    public let value: DependentMiddle_open0_T_close0_DependentMiddle_open0_T_close0
    public func clone(): DependentOuter_DependentOuter {
        return this
    }
    public func toString(): String {
        var output = "DependentOuter_DependentOuter {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DependentMiddle_open0_T_close0_DependentMiddle_open0_T_close0) {
        this.value = value
    }
}

@C
public struct DirectUse_open0_int_close0_DirectUse_open0_int_close0 {
    public let value: Int32
    public func clone(): DirectUse_open0_int_close0_DirectUse_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "DirectUse_open0_int_close0_DirectUse_open0_int_close0 {"
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
        let size = sizeOf<DirectUse_open0_int_close0_DirectUse_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of DirectUse_open0_int_close0_DirectUse_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<DirectUse_open0_int_close0_DirectUse_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of DirectUse_open0_int_close0_DirectUse_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct NestedUse_open0_short_close0_NestedUse_open0_short_close0 {
    public let inner: NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner
    public func clone(): NestedUse_open0_short_close0_NestedUse_open0_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "NestedUse_open0_short_close0_NestedUse_open0_short_close0 {"
        output += " inner: "
        output += this.inner.toString()
        output += " }"
        return output
    }
    public init(
        inner: NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner) {
        this.inner = inner
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedUse_open0_short_close0_NestedUse_open0_short_close0>()
        if (size != 2) {
            throw Exception(
                "Size of NestedUse_open0_short_close0_NestedUse_open0_short_close0 is not 2 but ${size} bytes")
        }
        let align = alignOf<NestedUse_open0_short_close0_NestedUse_open0_short_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of NestedUse_open0_short_close0_NestedUse_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner {
    public let value: Int16
    public func clone(): NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner {
        return this
    }
    public func toString(): String {
        var output = "NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int16) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner>()
        if (size != 2) {
            throw Exception(
                "Size of NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner is not 2 but ${size} bytes")
        }
        let align = alignOf<NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner>()
        if (align != 2) {
            throw Exception(
                "Alignment of NestedUse_open0_short_close0_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner is not 2 but ${align} bytes")
        }
}

@C
public struct NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public func clone(): NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0 {
        return this
    }
    public func toString(): String {
        var output = "NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0 {"
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
        let size = sizeOf<NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0>()
        if (size != 16) {
            throw Exception(
                "Size of NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct NestedTemplateUse_Inner_open0_long_close0_Inner_open0_long_close0 {
    public let outer: UInt8
    public let inner: Int64
    public func clone(): NestedTemplateUse_Inner_open0_long_close0_Inner_open0_long_close0 {
        return this
    }
    public func toString(): String {
        var output = "NestedTemplateUse_Inner_open0_long_close0_Inner_open0_long_close0 {"
        output += " outer: "
        output += this.outer.toString()
        output += ", inner: "
        output += this.inner.toString()
        output += " }"
        return output
    }
    public init(outer: UInt8, inner: Int64) {
        this.outer = outer
        this.inner = inner
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedTemplateUse_Inner_open0_long_close0_Inner_open0_long_close0>()
        if (size != 16) {
            throw Exception(
                "Size of NestedTemplateUse_Inner_open0_long_close0_Inner_open0_long_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<NestedTemplateUse_Inner_open0_long_close0_Inner_open0_long_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of NestedTemplateUse_Inner_open0_long_close0_Inner_open0_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct NestedTemplateIgnore_Inner_Inner {
    public let value: Int32
    public func clone(): NestedTemplateIgnore_Inner_Inner {
        return this
    }
    public func toString(): String {
        var output = "NestedTemplateIgnore_Inner_Inner {"
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
        let size = sizeOf<NestedTemplateIgnore_Inner_Inner>()
        if (size != 4) {
            throw Exception("Size of NestedTemplateIgnore_Inner_Inner is not 4 but ${size} bytes")
        }
        let align = alignOf<NestedTemplateIgnore_Inner_Inner>()
        if (align != 4) {
            throw Exception("Alignment of NestedTemplateIgnore_Inner_Inner is not 4 but ${align} bytes")
        }
}

@C
public struct AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0 {
    public let value: AliasUse_open0_long_long_close0_Alias_Alias
    public func clone(): AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0 {
        return this
    }
    public func toString(): String {
        var output = "AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: AliasUse_open0_long_long_close0_Alias_Alias) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0>()
        if (size != 8) {
            throw Exception(
                "Size of AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0 is not 8 but ${align} bytes")
        }
}

public type AliasUse_open0_long_long_close0_Alias_Alias = Int64

@C
public struct SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0 {
    public let first: Int32
    public let third: UInt8
    public func clone(): SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0 {
        return this
    }
    public func toString(): String {
        var output = "SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0 {"
        output += " first: "
        output += this.first.toString()
        output += ", third: "
        output += this.third.toString()
        output += " }"
        return output
    }
    public init(first: Int32, third: UInt8) {
        this.first = first
        this.third = third
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0>()
        if (size != 8) {
            throw Exception(
                "Size of SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0 {
    public let first: TypedefAndAliasUse_open0_unsigned_int_double_close0_First_First
    public let second: TypedefAndAliasUse_open0_unsigned_int_double_close0_Second_Second
    public func clone(): TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0 {
        return this
    }
    public func toString(): String {
        var output = "TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0 {"
        output += " first: "
        output += this.first.toString()
        output += ", second: "
        output += this.second.toString()
        output += " }"
        return output
    }
    public init(first: TypedefAndAliasUse_open0_unsigned_int_double_close0_First_First,
        second: TypedefAndAliasUse_open0_unsigned_int_double_close0_Second_Second) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0>()
        if (size != 16) {
            throw Exception(
                "Size of TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0 is not 8 but ${align} bytes")
        }
}

public type TypedefAndAliasUse_open0_unsigned_int_double_close0_First_First = UInt32

public type TypedefAndAliasUse_open0_unsigned_int_double_close0_Second_Second = Float64

@C
public struct NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_NestedAliasOnly_open0_long_float_close0_Inner {
    public let first: NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_First_First
    public let second: NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_Second_Second
    public func clone(): NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_NestedAliasOnly_open0_long_float_close0_Inner {
        return this
    }
    public func toString(): String {
        var output = "NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_NestedAliasOnly_open0_long_float_close0_Inner {"
        output += " first: "
        output += this.first.toString()
        output += ", second: "
        output += this.second.toString()
        output += " }"
        return output
    }
    public init(first: NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_First_First,
        second: NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_Second_Second) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_NestedAliasOnly_open0_long_float_close0_Inner>()
        if (size != 16) {
            throw Exception(
                "Size of NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_NestedAliasOnly_open0_long_float_close0_Inner is not 16 but ${size} bytes")
        }
        let align = alignOf<NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_NestedAliasOnly_open0_long_float_close0_Inner>()
        if (align != 8) {
            throw Exception(
                "Alignment of NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_NestedAliasOnly_open0_long_float_close0_Inner is not 8 but ${align} bytes")
        }
}

public type NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_First_First = Int64

public type NestedAliasOnly_NestedAliasOnly_open0_long_float_close0_Inner_Second_Second = Float32

@C
public struct DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0 {
    public let value: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner
    public func clone(): DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0 {
        return this
    }
    public func toString(): String {
        var output = "DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(
        value: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0>()
        if (size != 16) {
            throw Exception(
                "Size of DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner {
    public let first: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_First_First
    public let second: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_Second_Second
    public func clone(): DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner {
        return this
    }
    public func toString(): String {
        var output = "DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner {"
        output += " first: "
        output += this.first.toString()
        output += ", second: "
        output += this.second.toString()
        output += " }"
        return output
    }
    public init(
        first: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_First_First,
        second: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_Second_Second) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner>()
        if (size != 16) {
            throw Exception(
                "Size of DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner is not 16 but ${size} bytes")
        }
        let align = alignOf<DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner>()
        if (align != 8) {
            throw Exception(
                "Alignment of DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner is not 8 but ${align} bytes")
        }
}

public type DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_First_First = Int64

public type DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_bool_close0_Inner_Second_Second = Float32

@C
public struct CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0 {
    public let _base: BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0
    public let value: Int16
    public func clone(): CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(
        _base: BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0,
        value: Int16) {
        this._base = _base
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0>()
        if (size != 16) {
            throw Exception(
                "Size of CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0 {
    public let value: CPointer<CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0>
    public func clone(): BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0 {
        return this
    }
    public func toString(): String {
        var output = "BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0 {"
        output += " value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: CPointer<CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0>()
        if (size != 8) {
            throw Exception(
                "Size of BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0_BaseUsesParameter_open0_CrtpDirectUse_open0_short_close0_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0 {
    public let _base: BaseIgnoresParameter_BaseIgnoresParameter
    public let value: UInt16
    public func clone(): CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(_base: BaseIgnoresParameter_BaseIgnoresParameter, value: UInt16) {
        this._base = _base
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0>()
        if (size != 8) {
            throw Exception(
                "Size of CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0 {
    public let _base: BaseIgnoresParameter_BaseIgnoresParameter
    public let value: Int32
    public func clone(): CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(_base: BaseIgnoresParameter_BaseIgnoresParameter, value: Int32) {
        this._base = _base
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0>()
        if (size != 8) {
            throw Exception(
                "Size of CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0 {
    public let _base: BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0
    public let value: Int32
    public func clone(): CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(
        _base: BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0,
        value: Int32) {
        this._base = _base
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0>()
        if (size != 16) {
            throw Exception(
                "Size of CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0 {
    public let value: CPointer<CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0>
    public func clone(): BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0 {
        return this
    }
    public func toString(): String {
        var output = "BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0 {"
        output += " value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: CPointer<CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0>()
        if (size != 8) {
            throw Exception(
                "Size of BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0_BaseUsesParameter_open0_CrtpIndirectUse_open0_double_close0_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DependentMiddle_DependentMiddle {
    public let value: DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0
    public func clone(): DependentMiddle_DependentMiddle {
        return this
    }
    public func toString(): String {
        var output = "DependentMiddle_DependentMiddle {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentMiddle_DependentMiddle>()
        if (size != 8) {
            throw Exception("Size of DependentMiddle_DependentMiddle is not 8 but ${size} bytes")
        }
        let align = alignOf<DependentMiddle_DependentMiddle>()
        if (align != 8) {
            throw Exception("Alignment of DependentMiddle_DependentMiddle is not 8 but ${align} bytes")
        }
}

@C
public struct DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0 {
    public let value: UInt64
    public func clone(): DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0 {
        return this
    }
    public func toString(): String {
        var output = "DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: UInt64) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0>()
        if (size != 8) {
            throw Exception(
                "Size of DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of DependentLeaf_open0_unsigned_long_long_close0_DependentLeaf_open0_unsigned_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DependentMiddle_open0_unsigned_long_long_close0_DependentMiddle_open0_unsigned_long_long_close0 {
    let _cjbind_opaque_blob: UInt64
    public func clone(): DependentMiddle_open0_unsigned_long_long_close0_DependentMiddle_open0_unsigned_long_long_close0 {
        return this
    }
    public func toString(): String {
        var output = "DependentMiddle_open0_unsigned_long_long_close0_DependentMiddle_open0_unsigned_long_long_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DependentMiddle_open0_unsigned_long_long_close0_DependentMiddle_open0_unsigned_long_long_close0>()
        if (size != 8) {
            throw Exception(
                "Size of DependentMiddle_open0_unsigned_long_long_close0_DependentMiddle_open0_unsigned_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<DependentMiddle_open0_unsigned_long_long_close0_DependentMiddle_open0_unsigned_long_long_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of DependentMiddle_open0_unsigned_long_long_close0_DependentMiddle_open0_unsigned_long_long_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct TemplateParameterAnalysisHolder_TemplateParameterAnalysisHolder {
    public let direct: DirectUse_open0_int_close0_DirectUse_open0_int_close0
    public let unused: UnusedParameter_UnusedParameter
    public let nested: NestedUse_open0_short_close0_NestedUse_open0_short_close0
    public let nestedTemplate: NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0
    public let nestedTemplateIgnore: NestedTemplateIgnore_NestedTemplateIgnore
    public let aliasUse: AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0
    public let aliasOnly: AliasOnly_AliasOnly
    public let skipMiddle: SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0
    public let aliases: TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0
    public let nestedAliasOnly: NestedAliasOnly_NestedAliasOnly
    public let doublyIndirect: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0
    public let staticOnly: StaticOnlyUse_StaticOnlyUse
    public let crtpDirect: CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0
    public let crtpIgnoringBase: CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0
    public let crtpIgnore: CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0
    public let crtpIndirect: CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0
    public let dependent: DependentOuter_DependentOuter
    public func clone(): TemplateParameterAnalysisHolder_TemplateParameterAnalysisHolder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParameterAnalysisHolder_TemplateParameterAnalysisHolder {"
        output += " direct: "
        output += this.direct.toString()
        output += ", unused: "
        output += this.unused.toString()
        output += ", nested: "
        output += this.nested.toString()
        output += ", nestedTemplate: "
        output += this.nestedTemplate.toString()
        output += ", nestedTemplateIgnore: "
        output += this.nestedTemplateIgnore.toString()
        output += ", aliasUse: "
        output += this.aliasUse.toString()
        output += ", aliasOnly: "
        output += this.aliasOnly.toString()
        output += ", skipMiddle: "
        output += this.skipMiddle.toString()
        output += ", aliases: "
        output += this.aliases.toString()
        output += ", nestedAliasOnly: "
        output += this.nestedAliasOnly.toString()
        output += ", doublyIndirect: "
        output += this.doublyIndirect.toString()
        output += ", staticOnly: "
        output += this.staticOnly.toString()
        output += ", crtpDirect: "
        output += this.crtpDirect.toString()
        output += ", crtpIgnoringBase: "
        output += this.crtpIgnoringBase.toString()
        output += ", crtpIgnore: "
        output += this.crtpIgnore.toString()
        output += ", crtpIndirect: "
        output += this.crtpIndirect.toString()
        output += ", dependent: "
        output += this.dependent.toString()
        output += " }"
        return output
    }
    public init(direct: DirectUse_open0_int_close0_DirectUse_open0_int_close0, unused: UnusedParameter_UnusedParameter,
        nested: NestedUse_open0_short_close0_NestedUse_open0_short_close0,
        nestedTemplate: NestedTemplateUse_open0_unsigned_char_close0_NestedTemplateUse_open0_unsigned_char_close0,
        nestedTemplateIgnore: NestedTemplateIgnore_NestedTemplateIgnore,
        aliasUse: AliasUse_open0_long_long_close0_AliasUse_open0_long_long_close0, aliasOnly: AliasOnly_AliasOnly,
        skipMiddle: SkipMiddleParameter_open0_int_char_close0_SkipMiddleParameter_open0_int_char_close0,
        aliases: TypedefAndAliasUse_open0_unsigned_int_double_close0_TypedefAndAliasUse_open0_unsigned_int_double_close0,
        nestedAliasOnly: NestedAliasOnly_NestedAliasOnly,
        doublyIndirect: DoublyIndirectUse_open0_long_float_close0_DoublyIndirectUse_open0_long_float_close0,
        staticOnly: StaticOnlyUse_StaticOnlyUse,
        crtpDirect: CrtpDirectUse_open0_short_close0_CrtpDirectUse_open0_short_close0,
        crtpIgnoringBase: CrtpUseWithIgnoringBase_open0_unsigned_short_close0_CrtpUseWithIgnoringBase_open0_unsigned_short_close0,
        crtpIgnore: CrtpIgnoreWithIgnoringBase_open0_float_close0_CrtpIgnoreWithIgnoringBase_open0_float_close0,
        crtpIndirect: CrtpIndirectUse_open0_double_close0_CrtpIndirectUse_open0_double_close0,
        dependent: DependentOuter_DependentOuter) {
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
        let size = sizeOf<TemplateParameterAnalysisHolder_TemplateParameterAnalysisHolder>()
        if (size != 168) {
            throw Exception(
                "Size of TemplateParameterAnalysisHolder_TemplateParameterAnalysisHolder is not 168 but ${size} bytes")
        }
        let align = alignOf<TemplateParameterAnalysisHolder_TemplateParameterAnalysisHolder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateParameterAnalysisHolder_TemplateParameterAnalysisHolder is not 8 but ${align} bytes")
        }
}

@C
public struct NestedUse_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner {
    public let value: Int16
    public func clone(): NestedUse_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner {
        return this
    }
    public func toString(): String {
        var output = "NestedUse_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int16) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedUse_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner>()
        if (size != 2) {
            throw Exception(
                "Size of NestedUse_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner is not 2 but ${size} bytes")
        }
        let align = alignOf<NestedUse_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner>()
        if (align != 2) {
            throw Exception(
                "Alignment of NestedUse_NestedUse_open0_short_close0_Inner_NestedUse_open0_short_close0_Inner is not 2 but ${align} bytes")
        }
}

@C
public struct DoublyIndirectUse_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner {
    public let first: Int64
    public let second: Float32
    public func clone(): DoublyIndirectUse_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner {
        return this
    }
    public func toString(): String {
        var output = "DoublyIndirectUse_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner {"
        output += " first: "
        output += this.first.toString()
        output += ", second: "
        output += this.second.toString()
        output += " }"
        return output
    }
    public init(first: Int64, second: Float32) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoublyIndirectUse_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner>()
        if (size != 16) {
            throw Exception(
                "Size of DoublyIndirectUse_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner is not 16 but ${size} bytes")
        }
        let align = alignOf<DoublyIndirectUse_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner>()
        if (align != 8) {
            throw Exception(
                "Alignment of DoublyIndirectUse_DoublyIndirectUse_open0_long_float_bool_close0_Inner_DoublyIndirectUse_open0_long_float_bool_close0_Inner is not 8 but ${align} bytes")
        }
}
