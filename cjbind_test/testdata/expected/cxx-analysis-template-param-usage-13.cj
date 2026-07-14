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
public struct CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0 {
    public let _base: BaseIgnoresT_BaseIgnoresT
    public let usage: UInt16
    public func clone(): CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0 {
        return this
    }
    public func toString(): String {
        var output = "CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0 {"
        output += " _base: "
        output += this._base.toString()
        output += ", usage: "
        output += this.usage.toString()
        output += " }"
        return output
    }
    public init(_base: BaseIgnoresT_BaseIgnoresT, usage: UInt16) {
        this._base = _base
        this.usage = usage
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0>()
        if (size != 8) {
            throw Exception(
                "Size of CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateParamUsage13Holder_TemplateParamUsage13Holder {
    public let value: CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0
    public func clone(): TemplateParamUsage13Holder_TemplateParamUsage13Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage13Holder_TemplateParamUsage13Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: CrtpUsesU_open0_unsigned_short_close0_CrtpUsesU_open0_unsigned_short_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage13Holder_TemplateParamUsage13Holder>()
        if (size != 8) {
            throw Exception("Size of TemplateParamUsage13Holder_TemplateParamUsage13Holder is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage13Holder_TemplateParamUsage13Holder>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateParamUsage13Holder_TemplateParamUsage13Holder is not 4 but ${align} bytes")
        }
}
