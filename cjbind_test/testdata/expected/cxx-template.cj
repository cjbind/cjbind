package cjbind_ffi

public type BoxPtr<T> = CPointer<Unit>

public type Ptr<T> = CPointer<T>

@C
public struct Holder {
    public let integers: Box_open0_int_close0
    public let doubles: Box_open0_double_close0
    public let specialized: Box_open0_char_close0
    public let nested: Wrap_open0_int_close0
    public let fixed: Fixed_open0_4_close0
    public let largerFixed: Fixed_open0_8_close0
    public let negative: Tag_open0_minus_1_close0
    public let escaped: CharTag_open0_10_close0
    public let defaulted: DefaultBox_open0_int_close0
    public let explicitDefault: DefaultBox_open0_int_close0
    public let callbackWrap: CallbackWrap_open0_int_close0
    private init(integers: Box_open0_int_close0, doubles: Box_open0_double_close0, specialized: Box_open0_char_close0,
        nested: Wrap_open0_int_close0, fixed: Fixed_open0_4_close0, largerFixed: Fixed_open0_8_close0,
        negative: Tag_open0_minus_1_close0, escaped: CharTag_open0_10_close0, defaulted: DefaultBox_open0_int_close0,
        explicitDefault: DefaultBox_open0_int_close0, callbackWrap: CallbackWrap_open0_int_close0) {
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
        let size = sizeOf<Holder>()
        if (size != 104) {
            throw Exception("Size of Holder is not 104 but ${size} bytes")
        }
        let align = alignOf<Holder>()
        if (align != 8) {
            throw Exception("Alignment of Holder is not 8 but ${align} bytes")
        }
}

@C
public struct AliasHolder {
    public var value: CPointer<Unit>
    public var integer: Ptr<Int32>
    public var floating: Ptr<Float64>
    private init(value: CPointer<Unit>, integer: Ptr<Int32>, floating: Ptr<Float64>) {
        this.value = value
        this.integer = integer
        this.floating = floating
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasHolder>()
        if (size != 24) {
            throw Exception("Size of AliasHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<AliasHolder>()
        if (align != 8) {
            throw Exception("Alignment of AliasHolder is not 8 but ${align} bytes")
        }
}

foreign func _Z7consume3BoxIiE(value: Box_open0_int_close0): Unit

public unsafe func consume(value: Box_open0_int_close0): Unit {
    return _Z7consume3BoxIiE(value)
}

@C
public struct Box_open0_int_close0 {
    public var value: Int32
    public var pointer: CPointer<Int32>
    private init(value: Int32, pointer: CPointer<Int32>) {
        this.value = value
        this.pointer = pointer
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Box_open0_int_close0>()
        if (size != 16) {
            throw Exception("Size of Box_open0_int_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Box_open0_int_close0>()
        if (align != 8) {
            throw Exception("Alignment of Box_open0_int_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct CallbackWrap_open0_int_close0 {
    public var nested: CPointer<Box_open0_int_close0>
    public var callback: CFunc<(arg1: Int32) -> Int32>
    private init(nested: CPointer<Box_open0_int_close0>, callback: CFunc<(arg1: Int32) -> Int32>) {
        this.nested = nested
        this.callback = callback
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CallbackWrap_open0_int_close0>()
        if (size != 16) {
            throw Exception("Size of CallbackWrap_open0_int_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<CallbackWrap_open0_int_close0>()
        if (align != 8) {
            throw Exception("Alignment of CallbackWrap_open0_int_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DefaultBox_open0_int_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DefaultBox_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of DefaultBox_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<DefaultBox_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of DefaultBox_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct CharTag_open0_10_close0 {
    public var value: UInt8
    private init(value: UInt8) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<CharTag_open0_10_close0>()
        if (size != 1) {
            throw Exception("Size of CharTag_open0_10_close0 is not 1 but ${size} bytes")
        }
        let align = alignOf<CharTag_open0_10_close0>()
        if (align != 1) {
            throw Exception("Alignment of CharTag_open0_10_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct Tag_open0_minus_1_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Tag_open0_minus_1_close0>()
        if (size != 4) {
            throw Exception("Size of Tag_open0_minus_1_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Tag_open0_minus_1_close0>()
        if (align != 4) {
            throw Exception("Alignment of Tag_open0_minus_1_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct Fixed_open0_8_close0 {
    public let values: VArray<UInt8, $8>
    private init(values: VArray<UInt8, $8>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Fixed_open0_8_close0>()
        if (size != 8) {
            throw Exception("Size of Fixed_open0_8_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<Fixed_open0_8_close0>()
        if (align != 1) {
            throw Exception("Alignment of Fixed_open0_8_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct Fixed_open0_4_close0 {
    public let values: VArray<UInt8, $4>
    private init(values: VArray<UInt8, $4>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Fixed_open0_4_close0>()
        if (size != 4) {
            throw Exception("Size of Fixed_open0_4_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Fixed_open0_4_close0>()
        if (align != 1) {
            throw Exception("Alignment of Fixed_open0_4_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct Wrap_open0_int_close0 {
    public let nested: Box_open0_int_close0
    private init(nested: Box_open0_int_close0) {
        this.nested = nested
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Wrap_open0_int_close0>()
        if (size != 16) {
            throw Exception("Size of Wrap_open0_int_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Wrap_open0_int_close0>()
        if (align != 8) {
            throw Exception("Alignment of Wrap_open0_int_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Box_open0_char_close0 {
    public var specialized: Float64
    private init(specialized: Float64) {
        this.specialized = specialized
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Box_open0_char_close0>()
        if (size != 8) {
            throw Exception("Size of Box_open0_char_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<Box_open0_char_close0>()
        if (align != 8) {
            throw Exception("Alignment of Box_open0_char_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct Box_open0_double_close0 {
    public var value: Float64
    public var pointer: CPointer<Float64>
    private init(value: Float64, pointer: CPointer<Float64>) {
        this.value = value
        this.pointer = pointer
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Box_open0_double_close0>()
        if (size != 16) {
            throw Exception("Size of Box_open0_double_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Box_open0_double_close0>()
        if (align != 8) {
            throw Exception("Alignment of Box_open0_double_close0 is not 8 but ${align} bytes")
        }
}
