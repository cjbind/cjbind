package cjbind_ffi

public type BoxPtr<T> = CPointer<Unit>

public type Ptr<T> = CPointer<T>

@C
public struct Holder {
    public let integers: Box_open0_int_close0
    public let doubles: Box_open0_double_close0
    public let specialized: Box_open0_char_close0
    public let nested: VArray<UInt64, $2>
    public let fixed: VArray<UInt8, $4>
    public let largerFixed: VArray<UInt8, $8>
    public let negative: UInt32
    public let escaped: UInt8
    public let defaulted: DefaultBox_open0_int_close0
    public let explicitDefault: DefaultBox_open0_int_close0
    public let callbackWrap: VArray<UInt64, $2>
    public init(integers: Box_open0_int_close0, doubles: Box_open0_double_close0, specialized: Box_open0_char_close0,
        nested: VArray<UInt64, $2>, fixed: VArray<UInt8, $4>, largerFixed: VArray<UInt8, $8>, negative: UInt32,
        escaped: UInt8, defaulted: DefaultBox_open0_int_close0, explicitDefault: DefaultBox_open0_int_close0,
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
    public let value: CPointer<Unit>
    public let integer: Ptr<Int32>
    public let floating: Ptr<Float64>
    public init(value: CPointer<Unit>, integer: Ptr<Int32>, floating: Ptr<Float64>) {
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

@C
public struct Box_open0_int_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
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
public struct DefaultBox_open0_int_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
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
public struct Box_open0_char_close0 {
    let _cjbind_opaque_blob: UInt64
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
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
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
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
