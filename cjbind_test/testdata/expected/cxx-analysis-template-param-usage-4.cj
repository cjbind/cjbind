package cjbind_ffi

@C
public struct UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0 {
    public let t: UInt16
    public func clone(): UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0 {"
        output += " t: "
        output += this.t.toString()
        output += " }"
        return output
    }
    public init(t: UInt16) {
        this.t = t
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0>()
        if (size != 2) {
            throw Exception(
                "Size of UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0 is not 2 but ${size} bytes")
        }
        let align = alignOf<UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage4Holder_TemplateParamUsage4Holder {
    public let value: UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0
    public func clone(): TemplateParamUsage4Holder_TemplateParamUsage4Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage4Holder_TemplateParamUsage4Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(
        value: UsesTemplateParameter_open0_unsigned_short_close0_UsesTemplateParameter_open0_unsigned_short_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage4Holder_TemplateParamUsage4Holder>()
        if (size != 2) {
            throw Exception("Size of TemplateParamUsage4Holder_TemplateParamUsage4Holder is not 2 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage4Holder_TemplateParamUsage4Holder>()
        if (align != 2) {
            throw Exception(
                "Alignment of TemplateParamUsage4Holder_TemplateParamUsage4Holder is not 2 but ${align} bytes")
        }
}
