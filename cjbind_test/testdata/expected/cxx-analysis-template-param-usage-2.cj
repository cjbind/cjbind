package cjbind_ffi

@C
public struct UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0 {
    public let t: Int16
    public func clone(): UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0 {"
        output += " t: "
        output += this.t.toString()
        output += " }"
        return output
    }
    public init(t: Int16) {
        this.t = t
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0>()
        if (size != 2) {
            throw Exception(
                "Size of UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0 is not 2 but ${size} bytes")
        }
        let align = alignOf<UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter {
    public let also: Int16
    public func clone(): UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter {
        return this
    }
    public func toString(): String {
        var output = "UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter {"
        output += " also: "
        output += this.also.toString()
        output += " }"
        return output
    }
    public init(also: Int16) {
        this.also = also
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter>()
        if (size != 2) {
            throw Exception(
                "Size of UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter is not 2 but ${size} bytes")
        }
        let align = alignOf<UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter>()
        if (align != 2) {
            throw Exception(
                "Alignment of UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter_UsesTemplateParameter_open0_short_close0_AlsoUsesTemplateParameter is not 2 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage2Holder_TemplateParamUsage2Holder {
    public let value: UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0
    public func clone(): TemplateParamUsage2Holder_TemplateParamUsage2Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage2Holder_TemplateParamUsage2Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: UsesTemplateParameter_open0_short_close0_UsesTemplateParameter_open0_short_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage2Holder_TemplateParamUsage2Holder>()
        if (size != 2) {
            throw Exception("Size of TemplateParamUsage2Holder_TemplateParamUsage2Holder is not 2 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage2Holder_TemplateParamUsage2Holder>()
        if (align != 2) {
            throw Exception(
                "Alignment of TemplateParamUsage2Holder_TemplateParamUsage2Holder is not 2 but ${align} bytes")
        }
}
