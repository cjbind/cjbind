package cjbind_ffi

@C
public struct DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0 {
    public let t: Int32
    public let v: UInt8
    public func clone(): DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0 {
        return this
    }
    public func toString(): String {
        var output = "DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0 {"
        output += " t: "
        output += this.t.toString()
        output += ", v: "
        output += this.v.toString()
        output += " }"
        return output
    }
    public init(t: Int32, v: UInt8) {
        this.t = t
        this.v = v
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0>()
        if (size != 8) {
            throw Exception(
                "Size of DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0 is not 4 but ${align} bytes")
        }
}

public type Alias_Alias = DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0

@C
public struct TemplateParamUsage7Holder_TemplateParamUsage7Holder {
    public let value: DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0
    public func clone(): TemplateParamUsage7Holder_TemplateParamUsage7Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage7Holder_TemplateParamUsage7Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DoesNotUseU_open0_int_char_close0_DoesNotUseU_open0_int_char_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage7Holder_TemplateParamUsage7Holder>()
        if (size != 8) {
            throw Exception("Size of TemplateParamUsage7Holder_TemplateParamUsage7Holder is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage7Holder_TemplateParamUsage7Holder>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateParamUsage7Holder_TemplateParamUsage7Holder is not 4 but ${align} bytes")
        }
}
