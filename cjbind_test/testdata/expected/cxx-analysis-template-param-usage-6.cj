package cjbind_ffi

public type DoesNotUseTemplateParameter_ButAliasDoesUseIt_ButAliasDoesUseIt<T> = T

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

public type EndpointCallback_EndpointCallback<T, V> = CFunc<(arg1: V) -> T>

@C
public struct TemplateParamUsage6Holder_TemplateParamUsage6Holder {
    public let value: DoesNotUseTemplateParameter_DoesNotUseTemplateParameter
    public func clone(): TemplateParamUsage6Holder_TemplateParamUsage6Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage6Holder_TemplateParamUsage6Holder {"
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
        let size = sizeOf<TemplateParamUsage6Holder_TemplateParamUsage6Holder>()
        if (size != 4) {
            throw Exception("Size of TemplateParamUsage6Holder_TemplateParamUsage6Holder is not 4 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage6Holder_TemplateParamUsage6Holder>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateParamUsage6Holder_TemplateParamUsage6Holder is not 4 but ${align} bytes")
        }
}
