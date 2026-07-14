package cjbind_ffi

public type IndirectlyUsesTemplateParameter_Aliased_Aliased<T> = T

@C
public struct IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0 {
    public let aliased: IndirectlyUsesTemplateParameter_open0_long_long_close0_Aliased_Aliased
    public func clone(): IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0 {
        return this
    }
    public func toString(): String {
        var output = "IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0 {"
        output += " aliased: "
        output += this.aliased.toString()
        output += " }"
        return output
    }
    public init(aliased: IndirectlyUsesTemplateParameter_open0_long_long_close0_Aliased_Aliased) {
        this.aliased = aliased
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0>()
        if (size != 8) {
            throw Exception(
                "Size of IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0 is not 8 but ${align} bytes")
        }
}

public type IndirectlyUsesTemplateParameter_open0_long_long_close0_Aliased_Aliased = Int64

@C
public struct TemplateParamUsage5Holder_TemplateParamUsage5Holder {
    public let value: IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0
    public func clone(): TemplateParamUsage5Holder_TemplateParamUsage5Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage5Holder_TemplateParamUsage5Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(
        value: IndirectlyUsesTemplateParameter_open0_long_long_close0_IndirectlyUsesTemplateParameter_open0_long_long_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage5Holder_TemplateParamUsage5Holder>()
        if (size != 8) {
            throw Exception("Size of TemplateParamUsage5Holder_TemplateParamUsage5Holder is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage5Holder_TemplateParamUsage5Holder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateParamUsage5Holder_TemplateParamUsage5Holder is not 8 but ${align} bytes")
        }
}
