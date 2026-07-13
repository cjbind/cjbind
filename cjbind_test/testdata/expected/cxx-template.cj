package cjbind_ffi

@C
public struct Box_open0_char_close0_Box_open0_char_close0 {
    public let specialized: Float64
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

@C
public struct Holder_Box_open0_int_close0_Box_open0_int_close0 {
    public let value: Int32
    public let pointer: CPointer<Int32>
    public init(value: Int32, pointer: CPointer<Int32>) {
        this.value = value
        this.pointer = pointer
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Holder_Box_open0_int_close0_Box_open0_int_close0>()
        if (size != 16) {
            throw Exception("Size of Holder_Box_open0_int_close0_Box_open0_int_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Holder_Box_open0_int_close0_Box_open0_int_close0>()
        if (align != 8) {
            throw Exception("Alignment of Holder_Box_open0_int_close0_Box_open0_int_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Holder_Box_open0_double_close0_Box_open0_double_close0 {
    public let value: Float64
    public let pointer: CPointer<Float64>
    public init(value: Float64, pointer: CPointer<Float64>) {
        this.value = value
        this.pointer = pointer
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Holder_Box_open0_double_close0_Box_open0_double_close0>()
        if (size != 16) {
            throw Exception(
                "Size of Holder_Box_open0_double_close0_Box_open0_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Holder_Box_open0_double_close0_Box_open0_double_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of Holder_Box_open0_double_close0_Box_open0_double_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Holder_Box_open0_char_close0_Box_open0_char_close0 {
    public let specialized: Float64
    public init(specialized: Float64) {
        this.specialized = specialized
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Holder_Box_open0_char_close0_Box_open0_char_close0>()
        if (size != 8) {
            throw Exception("Size of Holder_Box_open0_char_close0_Box_open0_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<Holder_Box_open0_char_close0_Box_open0_char_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of Holder_Box_open0_char_close0_Box_open0_char_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Holder_CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Holder_CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0>()
        if (size != 1) {
            throw Exception(
                "Size of Holder_CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 is not 1 but ${size} bytes")
        }
        let align = alignOf<Holder_CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0>()
        if (align != 1) {
            throw Exception(
                "Alignment of Holder_CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct Holder_Holder {
    public let integers: Holder_Box_open0_int_close0_Box_open0_int_close0
    public let doubles: Holder_Box_open0_double_close0_Box_open0_double_close0
    public let specialized: Holder_Box_open0_char_close0_Box_open0_char_close0
    public let nested: VArray<UInt64, $2>
    public let fixed: VArray<UInt8, $4>
    public let largerFixed: VArray<UInt8, $8>
    public let negative: UInt32
    public let escaped: Holder_CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0
    public let defaulted: Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0
    public let explicitDefault: Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0
    public let callbackWrap: VArray<UInt64, $2>
    public init(integers: Holder_Box_open0_int_close0_Box_open0_int_close0,
        doubles: Holder_Box_open0_double_close0_Box_open0_double_close0,
        specialized: Holder_Box_open0_char_close0_Box_open0_char_close0, nested: VArray<UInt64, $2>,
        fixed: VArray<UInt8, $4>, largerFixed: VArray<UInt8, $8>, negative: UInt32,
        escaped: Holder_CharTag_open0_quote__u92_n_quote_close0_CharTag_open0_quote__u92_n_quote_close0,
        defaulted: Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0,
        explicitDefault: Holder_DefaultBox_open0_int_close0_DefaultBox_open0_int_close0,
        callbackWrap: VArray<UInt64, $2>) {
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

@C
public struct Box_open0_int_close0_Box_open0_int_close0 {
    public let value: Int32
    public let pointer: CPointer<Int32>
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

foreign func _Z7consume3BoxIiE(value: Box_open0_int_close0_Box_open0_int_close0): Unit

public unsafe func consume(value: Box_open0_int_close0_Box_open0_int_close0): Unit {
    return _Z7consume3BoxIiE(value)
}
