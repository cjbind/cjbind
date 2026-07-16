package cjbind_ffi

public type FixedInts = FixedArray_open0_int_4_close0

@C
public struct AliasHolder {
    public let chars: FixedArray_open0_char_16_close0
    public let flags: FixedArray_open0_bool_8_close0
    public let integers: FixedInts
    public let defaulted: PairWithDefault_open0_bool_int_close0
    private init(chars: FixedArray_open0_char_16_close0, flags: FixedArray_open0_bool_8_close0, integers: FixedInts,
        defaulted: PairWithDefault_open0_bool_int_close0) {
        this.chars = chars
        this.flags = flags
        this.integers = integers
        this.defaulted = defaulted
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasHolder>()
        if (size != 48) {
            throw Exception("Size of AliasHolder is not 48 but ${size} bytes")
        }
        let align = alignOf<AliasHolder>()
        if (align != 4) {
            throw Exception("Alignment of AliasHolder is not 4 but ${align} bytes")
        }
}

@C
public struct PairWithDefault_open0_bool_int_close0 {
    public var first: Bool
    public var second: Int32
    private init(first: Bool, second: Int32) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PairWithDefault_open0_bool_int_close0>()
        if (size != 8) {
            throw Exception("Size of PairWithDefault_open0_bool_int_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<PairWithDefault_open0_bool_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of PairWithDefault_open0_bool_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct FixedArray_open0_bool_8_close0 {
    public let values: VArray<Bool, $8>
    private init(values: VArray<Bool, $8>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FixedArray_open0_bool_8_close0>()
        if (size != 8) {
            throw Exception("Size of FixedArray_open0_bool_8_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<FixedArray_open0_bool_8_close0>()
        if (align != 1) {
            throw Exception("Alignment of FixedArray_open0_bool_8_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct FixedArray_open0_char_16_close0 {
    public let values: VArray<UInt8, $16>
    private init(values: VArray<UInt8, $16>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FixedArray_open0_char_16_close0>()
        if (size != 16) {
            throw Exception("Size of FixedArray_open0_char_16_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<FixedArray_open0_char_16_close0>()
        if (align != 1) {
            throw Exception("Alignment of FixedArray_open0_char_16_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct FixedArray_open0_int_4_close0 {
    public let values: VArray<Int32, $4>
    private init(values: VArray<Int32, $4>) {
        this.values = values
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FixedArray_open0_int_4_close0>()
        if (size != 16) {
            throw Exception("Size of FixedArray_open0_int_4_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<FixedArray_open0_int_4_close0>()
        if (align != 4) {
            throw Exception("Alignment of FixedArray_open0_int_4_close0 is not 4 but ${align} bytes")
        }
}
