package cjbind_ffi

@C
public struct UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0 {
    public let t: UInt8
    public func clone(): UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0 {
        return this
    }
    public func toString(): String {
        var output = "UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0 {"
        output += " t: "
        output += this.t.toString()
        output += " }"
        return output
    }
    public init(t: UInt8) {
        this.t = t
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0>()
        if (size != 1) {
            throw Exception(
                "Size of UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0 is not 1 but ${size} bytes")
        }
        let align = alignOf<UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0>()
        if (align != 1) {
            throw Exception(
                "Alignment of UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0 {
    public let also: UInt8
    public let more: Int16
    public func clone(): UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0 {"
        output += " also: "
        output += this.also.toString()
        output += ", more: "
        output += this.more.toString()
        output += " }"
        return output
    }
    public init(also: UInt8, more: Int16) {
        this.also = also
        this.more = more
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0>()
        if (size != 4) {
            throw Exception(
                "Size of UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0>()
        if (align != 2) {
            throw Exception(
                "Alignment of UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0 is not 2 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage3Holder_TemplateParamUsage3Holder {
    public let value: UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0
    public let nested: UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0
    public func clone(): TemplateParamUsage3Holder_TemplateParamUsage3Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage3Holder_TemplateParamUsage3Holder {"
        output += " value: "
        output += this.value.toString()
        output += ", nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(
        value: UsesTemplateParameter_open0_unsigned_char_close0_UsesTemplateParameter_open0_unsigned_char_close0,
        nested: UsesTemplateParameter_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0_UsesTemplateParameter_open0_unsigned_char_close0_AlsoUsesTemplateParameterAndMore_open0_short_close0) {
        this.value = value
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage3Holder_TemplateParamUsage3Holder>()
        if (size != 6) {
            throw Exception("Size of TemplateParamUsage3Holder_TemplateParamUsage3Holder is not 6 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage3Holder_TemplateParamUsage3Holder>()
        if (align != 2) {
            throw Exception(
                "Alignment of TemplateParamUsage3Holder_TemplateParamUsage3Holder is not 2 but ${align} bytes")
        }
}
