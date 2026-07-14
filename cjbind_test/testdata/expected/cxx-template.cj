package cjbind_ffi

@C
public struct Box_open0_char_close0_Box_open0_char_close0 {
    public let specialized: Float64
    public func clone(): Box_open0_char_close0_Box_open0_char_close0 {
        return this
    }
    public func toString(): String {
        var output = "Box_open0_char_close0_Box_open0_char_close0 {"
        output += " specialized: "
        output += this.specialized.toString()
        output += " }"
        return output
    }
    public init(specialized: Float64) {
        this.specialized = specialized
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Box_open0_char_close0_Box_open0_char_close0>()
        if (size != 8) {
            throw Exception("Size of Box_open0_char_close0_Box_open0_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<Box_open0_char_close0_Box_open0_char_close0>()
        if (align != 8) {
            throw Exception("Alignment of Box_open0_char_close0_Box_open0_char_close0 is not 8 but ${align} bytes")
        }
}

public type BoxPtr_BoxPtr = CPointer<Box_Box>

public type Ptr_Ptr<T> = CPointer<T>

@C
public struct Box_open0_int_close0_Box_open0_int_close0 {
    public let value: Int32
    public let pointer: CPointer<Int32>
    public func clone(): Box_open0_int_close0_Box_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "Box_open0_int_close0_Box_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += ", pointer: "
        output += CPointer<Unit>(this.pointer).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: Int32, pointer: CPointer<Int32>) {
        this.value = value
        this.pointer = pointer
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Box_open0_int_close0_Box_open0_int_close0>()
        if (size != 16) {
            throw Exception("Size of Box_open0_int_close0_Box_open0_int_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Box_open0_int_close0_Box_open0_int_close0>()
        if (align != 8) {
            throw Exception("Alignment of Box_open0_int_close0_Box_open0_int_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Box_open0_double_close0_Box_open0_double_close0 {
    public let value: Float64
    public let pointer: CPointer<Float64>
    public func clone(): Box_open0_double_close0_Box_open0_double_close0 {
        return this
    }
    public func toString(): String {
        var output = "Box_open0_double_close0_Box_open0_double_close0 {"
        output += " value: "
        output += this.value.toString()
        output += ", pointer: "
        output += CPointer<Unit>(this.pointer).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: Float64, pointer: CPointer<Float64>) {
        this.value = value
        this.pointer = pointer
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Box_open0_double_close0_Box_open0_double_close0>()
        if (size != 16) {
            throw Exception("Size of Box_open0_double_close0_Box_open0_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Box_open0_double_close0_Box_open0_double_close0>()
        if (align != 8) {
            throw Exception("Alignment of Box_open0_double_close0_Box_open0_double_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Wrap_Wrap {
    public let nested: Box_open0_int_close0_Box_open0_int_close0
    public func clone(): Wrap_Wrap {
        return this
    }
    public func toString(): String {
        var output = "Wrap_Wrap {"
        output += " nested: "
        output += this.nested.toString()
        output += " }"
        return output
    }
    public init(nested: Box_open0_int_close0_Box_open0_int_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Wrap_Wrap>()
        if (size != 16) {
            throw Exception("Size of Wrap_Wrap is not 16 but ${size} bytes")
        }
        let align = alignOf<Wrap_Wrap>()
        if (align != 8) {
            throw Exception("Alignment of Wrap_Wrap is not 8 but ${align} bytes")
        }
}

@C
public struct Fixed_open0_4_close0_Fixed_open0_4_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $4>
    public func clone(): Fixed_open0_4_close0_Fixed_open0_4_close0 {
        return this
    }
    public func toString(): String {
        var output = "Fixed_open0_4_close0_Fixed_open0_4_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Fixed_open0_4_close0_Fixed_open0_4_close0>()
        if (size != 4) {
            throw Exception("Size of Fixed_open0_4_close0_Fixed_open0_4_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Fixed_open0_4_close0_Fixed_open0_4_close0>()
        if (align != 1) {
            throw Exception("Alignment of Fixed_open0_4_close0_Fixed_open0_4_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct Fixed_open0_8_close0_Fixed_open0_8_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $8>
    public func clone(): Fixed_open0_8_close0_Fixed_open0_8_close0 {
        return this
    }
    public func toString(): String {
        var output = "Fixed_open0_8_close0_Fixed_open0_8_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $8>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Fixed_open0_8_close0_Fixed_open0_8_close0>()
        if (size != 8) {
            throw Exception("Size of Fixed_open0_8_close0_Fixed_open0_8_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<Fixed_open0_8_close0_Fixed_open0_8_close0>()
        if (align != 1) {
            throw Exception("Alignment of Fixed_open0_8_close0_Fixed_open0_8_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct Tag_open0_minus_1_close0_Tag_open0_minus_1_close0 {
    public let value: Int32
    public func clone(): Tag_open0_minus_1_close0_Tag_open0_minus_1_close0 {
        return this
    }
    public func toString(): String {
        var output = "Tag_open0_minus_1_close0_Tag_open0_minus_1_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Tag_open0_minus_1_close0_Tag_open0_minus_1_close0>()
        if (size != 4) {
            throw Exception("Size of Tag_open0_minus_1_close0_Tag_open0_minus_1_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Tag_open0_minus_1_close0_Tag_open0_minus_1_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of Tag_open0_minus_1_close0_Tag_open0_minus_1_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 {
    public let value: UInt8
    public func clone(): CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 {
        return this
    }
    public func toString(): String {
        var output = "CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: UInt8) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0>()
        if (size != 1) {
            throw Exception(
                "Size of CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 is not 1 but ${size} bytes")
        }
        let align = alignOf<CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0>()
        if (align != 1) {
            throw Exception(
                "Alignment of CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 {
    public let value: Int32
    public func clone(): DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DefaultBox_open0_int_close0_DefaultBox_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<DefaultBox_open0_int_close0_DefaultBox_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0 {
    public let nested: CPointer<UInt32>
    public let callback: CFunc<(arg1: Int32) -> Int32>
    public func clone(): CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0 {"
        output += " nested: "
        output += CPointer<Unit>(this.nested).toUIntNative().toString()
        output += ", callback: "
        output += CPointer<Unit>(this.callback).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(nested: CPointer<UInt32>, callback: CFunc<(arg1: Int32) -> Int32>) {
        this.nested = nested
        this.callback = callback
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0>()
        if (size != 16) {
            throw Exception(
                "Size of CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Holder_Holder {
    public let integers: Box_open0_int_close0_Box_open0_int_close0
    public let doubles: Box_open0_double_close0_Box_open0_double_close0
    public let specialized: Box_open0_char_close0_Box_open0_char_close0
    public let nested: Wrap_Wrap
    public let fixed: Fixed_open0_4_close0_Fixed_open0_4_close0
    public let largerFixed: Fixed_open0_8_close0_Fixed_open0_8_close0
    public let negative: Tag_open0_minus_1_close0_Tag_open0_minus_1_close0
    public let escaped: CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0
    public let defaulted: DefaultBox_open0_int_close0_DefaultBox_open0_int_close0
    public let explicitDefault: DefaultBox_open0_int_close0_DefaultBox_open0_int_close0
    public let callbackWrap: CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0
    public func clone(): Holder_Holder {
        return this
    }
    public func toString(): String {
        var output = "Holder_Holder {"
        output += " integers: "
        output += this.integers.toString()
        output += ", doubles: "
        output += this.doubles.toString()
        output += ", specialized: "
        output += this.specialized.toString()
        output += ", nested: "
        output += this.nested.toString()
        output += ", fixed: "
        output += this.fixed.toString()
        output += ", largerFixed: "
        output += this.largerFixed.toString()
        output += ", negative: "
        output += this.negative.toString()
        output += ", escaped: "
        output += this.escaped.toString()
        output += ", defaulted: "
        output += this.defaulted.toString()
        output += ", explicitDefault: "
        output += this.explicitDefault.toString()
        output += ", callbackWrap: "
        output += this.callbackWrap.toString()
        output += " }"
        return output
    }
    public init(integers: Box_open0_int_close0_Box_open0_int_close0,
        doubles: Box_open0_double_close0_Box_open0_double_close0,
        specialized: Box_open0_char_close0_Box_open0_char_close0, nested: Wrap_Wrap,
        fixed: Fixed_open0_4_close0_Fixed_open0_4_close0, largerFixed: Fixed_open0_8_close0_Fixed_open0_8_close0,
        negative: Tag_open0_minus_1_close0_Tag_open0_minus_1_close0,
        escaped: CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0,
        defaulted: DefaultBox_open0_int_close0_DefaultBox_open0_int_close0,
        explicitDefault: DefaultBox_open0_int_close0_DefaultBox_open0_int_close0,
        callbackWrap: CallbackWrap_open0_int_close0_CallbackWrap_open0_int_close0) {
        this.integers = integers
        this.doubles = doubles
        this.specialized = specialized
        this.nested = nested
        this.fixed = fixed
        this.largerFixed = largerFixed
        this.negative = negative
        this.escaped = escaped
        this.defaulted = defaulted
        this.explicitDefault = explicitDefault
        this.callbackWrap = callbackWrap
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Holder_Holder>()
        if (size != 104) {
            throw Exception("Size of Holder_Holder is not 104 but ${size} bytes")
        }
        let align = alignOf<Holder_Holder>()
        if (align != 8) {
            throw Exception("Alignment of Holder_Holder is not 8 but ${align} bytes")
        }
}

@C
public struct AliasHolder_AliasHolder {
    public let value: CPointer<Box_open0_int_close0_Box_open0_int_close0>
    public let integer: CPointer<Int32>
    public let floating: CPointer<Float64>
    public func clone(): AliasHolder_AliasHolder {
        return this
    }
    public func toString(): String {
        var output = "AliasHolder_AliasHolder {"
        output += " value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += ", integer: "
        output += CPointer<Unit>(this.integer).toUIntNative().toString()
        output += ", floating: "
        output += CPointer<Unit>(this.floating).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: CPointer<Box_open0_int_close0_Box_open0_int_close0>, integer: CPointer<Int32>,
        floating: CPointer<Float64>) {
        this.value = value
        this.integer = integer
        this.floating = floating
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasHolder_AliasHolder>()
        if (size != 24) {
            throw Exception("Size of AliasHolder_AliasHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<AliasHolder_AliasHolder>()
        if (align != 8) {
            throw Exception("Alignment of AliasHolder_AliasHolder is not 8 but ${align} bytes")
        }
}

foreign func _Z7consume3BoxIiE(value: Box_open0_int_close0_Box_open0_int_close0): Unit

public unsafe func consume(value: Box_open0_int_close0_Box_open0_int_close0): Unit {
    return _Z7consume3BoxIiE(value)
}
