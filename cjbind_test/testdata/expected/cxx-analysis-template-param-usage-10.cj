package cjbind_ffi

public type DoublyIndirectUsage_Aliased_Aliased<T> = T

public type DoublyIndirectUsage_Typedefed_Typedefed<U> = U

@C
public struct DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0 {
    public let doubly_indirect: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage
    public func clone(): DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0 {
        return this
    }
    public func toString(): String {
        var output = "DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0 {"
        output += " doubly_indirect: "
        output += this.doubly_indirect.toString()
        output += " }"
        return output
    }
    public init(
        doubly_indirect: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage) {
        this.doubly_indirect = doubly_indirect
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0>()
        if (size != 16) {
            throw Exception(
                "Size of DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage {
    public let member: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_Aliased_Aliased
    public let another: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_Typedefed_Typedefed
    public func clone(): DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage {
        return this
    }
    public func toString(): String {
        var output = "DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage {"
        output += " member: "
        output += this.member.toString()
        output += ", another: "
        output += this.another.toString()
        output += " }"
        return output
    }
    public init(
        member: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_Aliased_Aliased,
        another: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_Typedefed_Typedefed) {
        this.member = member
        this.another = another
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage>()
        if (size != 16) {
            throw Exception(
                "Size of DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage is not 16 but ${size} bytes")
        }
        let align = alignOf<DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage>()
        if (align != 8) {
            throw Exception(
                "Alignment of DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage is not 8 but ${align} bytes")
        }
}

public type DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_Aliased_Aliased = Int64

public type DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_Typedefed_Typedefed = Float32

@C
public struct TemplateParamUsage10Holder_TemplateParamUsage10Holder {
    public let value: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0
    public func clone(): TemplateParamUsage10Holder_TemplateParamUsage10Holder {
        return this
    }
    public func toString(): String {
        var output = "TemplateParamUsage10Holder_TemplateParamUsage10Holder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: DoublyIndirectUsage_open0_long_float_close0_DoublyIndirectUsage_open0_long_float_close0) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateParamUsage10Holder_TemplateParamUsage10Holder>()
        if (size != 16) {
            throw Exception("Size of TemplateParamUsage10Holder_TemplateParamUsage10Holder is not 16 but ${size} bytes")
        }
        let align = alignOf<TemplateParamUsage10Holder_TemplateParamUsage10Holder>()
        if (align != 8) {
            throw Exception(
                "Alignment of TemplateParamUsage10Holder_TemplateParamUsage10Holder is not 8 but ${align} bytes")
        }
}

@C
public struct DoublyIndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage {
    public let member: Int64
    public let another: Float32
    public func clone(): DoublyIndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage {
        return this
    }
    public func toString(): String {
        var output = "DoublyIndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage {"
        output += " member: "
        output += this.member.toString()
        output += ", another: "
        output += this.another.toString()
        output += " }"
        return output
    }
    public init(member: Int64, another: Float32) {
        this.member = member
        this.another = another
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DoublyIndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage>()
        if (size != 16) {
            throw Exception(
                "Size of DoublyIndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage is not 16 but ${size} bytes")
        }
        let align = alignOf<DoublyIndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage>()
        if (align != 8) {
            throw Exception(
                "Alignment of DoublyIndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage_DoublyIndirectUsage_open0_long_float_bool_close0_IndirectUsage is not 8 but ${align} bytes")
        }
}
