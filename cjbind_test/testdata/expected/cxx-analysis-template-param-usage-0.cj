package cjbind_ffi

@C
public struct UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0 {
    public let t: Int32
    public func clone(): UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0 {"
        output += " t: "
        output += this.t.toString()
        output += " }"
        return output
    }
    public init(t: Int32) {
        this.t = t
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage0Holder_TemplateParamUsage0Holder {
    public let value: UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0
    public func clone(): TemplateParamUsage0Holder_TemplateParamUsage0Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage0Holder_TemplateParamUsage0Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: UsesTemplateParameter_open0_int_close0_UsesTemplateParameter_open0_int_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage0Holder_TemplateParamUsage0Holder>()
        if (size != 4) {
            throw Exception("Size of TemplateParamUsage0Holder_TemplateParamUsage0Holder is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage0Holder_TemplateParamUsage0Holder>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateParamUsage0Holder_TemplateParamUsage0Holder is not 4 but ${align} bytes")
        }
}
