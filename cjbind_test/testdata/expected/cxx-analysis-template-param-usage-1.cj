package cjbind_ffi

@C
public struct DoesNotUseTemplateParameter_DoesNotUseTemplateParameter {
    public let x: Int32
    public func clone(): DoesNotUseTemplateParameter_DoesNotUseTemplateParameter {
        return this
    }
    public func toString(): String {
        var output = "DoesNotUseTemplateParameter_DoesNotUseTemplateParameter {"
        output += " x: "
        output += this.x.toString()
        output += " }"
        return output
    }
    public init(x: Int32) {
        this.x = x
    }
}

@C
public struct TemplateParamUsage1Holder_TemplateParamUsage1Holder {
    public let value: DoesNotUseTemplateParameter_DoesNotUseTemplateParameter
    public func clone(): TemplateParamUsage1Holder_TemplateParamUsage1Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage1Holder_TemplateParamUsage1Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DoesNotUseTemplateParameter_DoesNotUseTemplateParameter) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage1Holder_TemplateParamUsage1Holder>()
        if (size != 4) {
            throw Exception("Size of TemplateParamUsage1Holder_TemplateParamUsage1Holder is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage1Holder_TemplateParamUsage1Holder>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateParamUsage1Holder_TemplateParamUsage1Holder is not 4 but ${align} bytes")
        }
}
