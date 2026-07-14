package cjbind_ffi

@C
public struct DoesNotUseT_DoesNotUseT {
    let _cjbind_empty: UInt8
    public func clone(): DoesNotUseT_DoesNotUseT {
        return this
    }
    public func toString(): String {
        var output = "DoesNotUseT_DoesNotUseT {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct TemplateParamUsage11Holder_TemplateParamUsage11Holder {
    public let value: DoesNotUseT_DoesNotUseT
    public func clone(): TemplateParamUsage11Holder_TemplateParamUsage11Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage11Holder_TemplateParamUsage11Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DoesNotUseT_DoesNotUseT) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage11Holder_TemplateParamUsage11Holder>()
        if (size != 1) {
            throw Exception("Size of TemplateParamUsage11Holder_TemplateParamUsage11Holder is not 1 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage11Holder_TemplateParamUsage11Holder>()
        if (align != 1) {
            throw Exception(
                "Alignment of TemplateParamUsage11Holder_TemplateParamUsage11Holder is not 1 but ${align} bytes")
        }
}
