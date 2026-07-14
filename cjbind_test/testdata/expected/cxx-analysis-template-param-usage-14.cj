package cjbind_ffi

@C
public struct BaseIgnoresT_BaseIgnoresT {
    public let x: Int32
    public func clone(): BaseIgnoresT_BaseIgnoresT {
        return this
    }
    public func toString(): String {
        var output = "BaseIgnoresT_BaseIgnoresT {"
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
public struct CrtpIgnoresU_CrtpIgnoresU {
    public let _base: BaseIgnoresT_BaseIgnoresT
    public let y: Int32
    public func clone(): CrtpIgnoresU_CrtpIgnoresU {
        return this
    }
    public func toString(): String {
        var output = "CrtpIgnoresU_CrtpIgnoresU {"
        output += " _base: "
        output += this._base.toString()
        output += ", y: "
        output += this.y.toString()
        output += " }"
        return output
    }
    public init(_base: BaseIgnoresT_BaseIgnoresT, y: Int32) {
        this._base = _base
        this.y = y
    }
}

@C
public struct CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0 {
    public let _base: BaseIgnoresT_BaseIgnoresT
    public let y: Int32
    public func clone(): CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", y: "
        output += this.y.toString()
        output += " }"
        return output
    }
    public init(_base: BaseIgnoresT_BaseIgnoresT, y: Int32) {
        this._base = _base
        this.y = y
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0>()
        if (size != 8) {
            throw Exception(
                "Size of CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage14Holder_TemplateParamUsage14Holder {
    public let value: CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0
    public func clone(): TemplateParamUsage14Holder_TemplateParamUsage14Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage14Holder_TemplateParamUsage14Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: CrtpIgnoresU_open0_float_close0_CrtpIgnoresU_open0_float_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage14Holder_TemplateParamUsage14Holder>()
        if (size != 8) {
            throw Exception("Size of TemplateParamUsage14Holder_TemplateParamUsage14Holder is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage14Holder_TemplateParamUsage14Holder>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateParamUsage14Holder_TemplateParamUsage14Holder is not 4 but ${align} bytes")
        }
}
