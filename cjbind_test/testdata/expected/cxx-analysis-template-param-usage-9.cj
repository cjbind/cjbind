package cjbind_ffi

public type DoesNotUse_Aliased_Aliased<T> = T

public type DoesNotUse_Typedefed_Typedefed<U> = U

@C
public struct DoesNotUse_DoesNotUse {
    let _cjbind_empty: UInt8
    public func clone(): DoesNotUse_DoesNotUse {
        return this
    }
    public func toString(): String {
        var output = "DoesNotUse_DoesNotUse {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_DoesNotUse_open0_long_float_close0_IndirectUsage {
    public let member: DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_Aliased_Aliased
    public let another: DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_Typedefed_Typedefed
    public func clone(): DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_DoesNotUse_open0_long_float_close0_IndirectUsage {
        return this
    }
    public func toString(): String {
        var output = "DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_DoesNotUse_open0_long_float_close0_IndirectUsage {"
        output += " member: "
        output += this.member.toString()
        output += ", another: "
        output += this.another.toString()
        output += " }"
        return output
    }
    public init(member: DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_Aliased_Aliased,
        another: DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_Typedefed_Typedefed) {
        this.member = member
        this.another = another
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_DoesNotUse_open0_long_float_close0_IndirectUsage>()
        if (size != 16) {
            throw Exception(
                "Size of DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_DoesNotUse_open0_long_float_close0_IndirectUsage is not 16 but ${size} bytes")
        }
        let align = alignOf<DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_DoesNotUse_open0_long_float_close0_IndirectUsage>()
        if (align != 8) {
            throw Exception(
                "Alignment of DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_DoesNotUse_open0_long_float_close0_IndirectUsage is not 8 but ${align} bytes")
        }
}

public type DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_Aliased_Aliased = Int64

public type DoesNotUse_DoesNotUse_open0_long_float_close0_IndirectUsage_Typedefed_Typedefed = Float32

@C
public struct DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_DoesNotUse_open0_char_short_close0_IndirectUsage {
    public let member: DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_Aliased_Aliased
    public let another: DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_Typedefed_Typedefed
    public func clone(): DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_DoesNotUse_open0_char_short_close0_IndirectUsage {
        return this
    }
    public func toString(): String {
        var output = "DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_DoesNotUse_open0_char_short_close0_IndirectUsage {"
        output += " member: "
        output += this.member.toString()
        output += ", another: "
        output += this.another.toString()
        output += " }"
        return output
    }
    public init(member: DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_Aliased_Aliased,
        another: DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_Typedefed_Typedefed) {
        this.member = member
        this.another = another
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_DoesNotUse_open0_char_short_close0_IndirectUsage>()
        if (size != 4) {
            throw Exception(
                "Size of DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_DoesNotUse_open0_char_short_close0_IndirectUsage is not 4 but ${size} bytes")
        }
        let align = alignOf<DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_DoesNotUse_open0_char_short_close0_IndirectUsage>()
        if (align != 2) {
            throw Exception(
                "Alignment of DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_DoesNotUse_open0_char_short_close0_IndirectUsage is not 2 but ${align} bytes")
        }
}

public type DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_Aliased_Aliased = UInt8

public type DoesNotUse_DoesNotUse_open0_char_short_close0_IndirectUsage_Typedefed_Typedefed = Int16

@C
public struct TemplateParamUsage9Holder_TemplateParamUsage9Holder {
    public let value: DoesNotUse_DoesNotUse
    public let other: DoesNotUse_DoesNotUse
    public func clone(): TemplateParamUsage9Holder_TemplateParamUsage9Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage9Holder_TemplateParamUsage9Holder {"
        output += " value: "
        output += this.value.toString()
        output += ", other: "
        output += this.other.toString()
        output += " }"
        return output
    }
    public init(value: DoesNotUse_DoesNotUse, other: DoesNotUse_DoesNotUse) {
        this.value = value
        this.other = other
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage9Holder_TemplateParamUsage9Holder>()
        if (size != 2) {
            throw Exception("Size of TemplateParamUsage9Holder_TemplateParamUsage9Holder is not 2 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage9Holder_TemplateParamUsage9Holder>()
        if (align != 1) {
            throw Exception(
                "Alignment of TemplateParamUsage9Holder_TemplateParamUsage9Holder is not 1 but ${align} bytes")
        }
}
