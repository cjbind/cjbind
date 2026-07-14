package cjbind_ffi

public type IndirectUsage_Typedefed_Typedefed<T> = T

public type IndirectUsage_Aliased_Aliased<U> = U

@C
public struct IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0 {
    public let member1: IndirectUsage_open0_unsigned_int_double_close0_Typedefed_Typedefed
    public let member2: IndirectUsage_open0_unsigned_int_double_close0_Aliased_Aliased
    public func clone(): IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0 {
        return this
    }
    public func toString(): String {
        var output = "IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0 {"
        output += " member1: "
        output += this.member1.toString()
        output += ", member2: "
        output += this.member2.toString()
        output += " }"
        return output
    }
    public init(member1: IndirectUsage_open0_unsigned_int_double_close0_Typedefed_Typedefed,
        member2: IndirectUsage_open0_unsigned_int_double_close0_Aliased_Aliased) {
        this.member1 = member1
        this.member2 = member2
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0>()
        if (size != 16) {
            throw Exception(
                "Size of IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0 is not 8 but ${align} bytes")
        }
}

public type IndirectUsage_open0_unsigned_int_double_close0_Typedefed_Typedefed = UInt32

public type IndirectUsage_open0_unsigned_int_double_close0_Aliased_Aliased = Float64

@C
public struct TemplateParamUsage8Holder_TemplateParamUsage8Holder {
    public let value: IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0
    public func clone(): TemplateParamUsage8Holder_TemplateParamUsage8Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage8Holder_TemplateParamUsage8Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: IndirectUsage_open0_unsigned_int_double_close0_IndirectUsage_open0_unsigned_int_double_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage8Holder_TemplateParamUsage8Holder>()
        if (size != 16) {
            throw Exception("Size of TemplateParamUsage8Holder_TemplateParamUsage8Holder is not 16 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage8Holder_TemplateParamUsage8Holder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateParamUsage8Holder_TemplateParamUsage8Holder is not 8 but ${align} bytes")
        }
}
