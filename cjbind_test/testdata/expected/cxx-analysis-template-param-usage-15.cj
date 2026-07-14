package cjbind_ffi

@C
public struct CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0 {
    public let _base: BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0
    public let y: Int32
    public func clone(): CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", y: "
        output += this.y.toString()
        output += " }"
        return output
    }
    public init(
        _base: BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0,
        y: Int32) {
        this._base = _base
        this.y = y
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0>()
        if (size != 16) {
            throw Exception(
                "Size of CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0 {
    public let usage: CPointer<CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0>
    public func clone(): BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0 {
        return this
    }
    public func toString(): String {
        var output = "BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0 {"
        output += " usage: "
        output += CPointer<Unit>(this.usage).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(usage: CPointer<CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0>) {
        this.usage = usage
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0>()
        if (size != 8) {
            throw Exception(
                "Size of BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0_BaseUsesT_open0_CrtpIgnoresU_open0_double_close0_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage15Holder_TemplateParamUsage15Holder {
    public let value: CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0
    public func clone(): TemplateParamUsage15Holder_TemplateParamUsage15Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage15Holder_TemplateParamUsage15Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: CrtpIgnoresU_open0_double_close0_CrtpIgnoresU_open0_double_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage15Holder_TemplateParamUsage15Holder>()
        if (size != 16) {
            throw Exception("Size of TemplateParamUsage15Holder_TemplateParamUsage15Holder is not 16 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage15Holder_TemplateParamUsage15Holder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateParamUsage15Holder_TemplateParamUsage15Holder is not 8 but ${align} bytes")
        }
}
