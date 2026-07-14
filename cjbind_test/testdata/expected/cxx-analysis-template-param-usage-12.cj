package cjbind_ffi

@C
public struct CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0 {
    public let _base: BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0
    public let usage: Int16
    public func clone(): CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", usage: "
        output += this.usage.toString()
        output += " }"
        return output
    }
    public init(
        _base: BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0,
        usage: Int16) {
        this._base = _base
        this.usage = usage
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0>()
        if (size != 16) {
            throw Exception(
                "Size of CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0 {
    public let t: CPointer<CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0>
    public func clone(): BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0 {
        return this
    }
    public func toString(): String {
        var output = "BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0 {"
        output += " t: "
        output += CPointer<Unit>(this.t).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(t: CPointer<CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0>) {
        this.t = t
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0>()
        if (size != 8) {
            throw Exception(
                "Size of BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0_BaseUsesT_open0_CrtpUsesU_open0_short_close0_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage12Holder_TemplateParamUsage12Holder {
    public let value: CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0
    public func clone(): TemplateParamUsage12Holder_TemplateParamUsage12Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage12Holder_TemplateParamUsage12Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: CrtpUsesU_open0_short_close0_CrtpUsesU_open0_short_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage12Holder_TemplateParamUsage12Holder>()
        if (size != 16) {
            throw Exception("Size of TemplateParamUsage12Holder_TemplateParamUsage12Holder is not 16 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage12Holder_TemplateParamUsage12Holder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateParamUsage12Holder_TemplateParamUsage12Holder is not 8 but ${align} bytes")
        }
}
