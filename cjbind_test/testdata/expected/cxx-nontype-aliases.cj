package cjbind_ffi

public type Fixed16_Fixed16 = FixedArray_FixedArray

@C
public struct FixedArray_open0_4_close0_FixedArray_open0_4_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $4>
    public func clone(): FixedArray_open0_4_close0_FixedArray_open0_4_close0 {
        return this
    }
    public func toString(): String {
        var output = "FixedArray_open0_4_close0_FixedArray_open0_4_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FixedArray_open0_4_close0_FixedArray_open0_4_close0>()
        if (size != 16) {
            throw Exception("Size of FixedArray_open0_4_close0_FixedArray_open0_4_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<FixedArray_open0_4_close0_FixedArray_open0_4_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of FixedArray_open0_4_close0_FixedArray_open0_4_close0 is not 4 but ${align} bytes")
        }
}

public type FixedInts_FixedInts = FixedArray_open0_4_close0_FixedArray_open0_4_close0

@C
public struct Fixed16_open0_16_close0_Fixed16_open0_16_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    public func clone(): Fixed16_open0_16_close0_Fixed16_open0_16_close0 {
        return this
    }
    public func toString(): String {
        var output = "Fixed16_open0_16_close0_Fixed16_open0_16_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Fixed16_open0_16_close0_Fixed16_open0_16_close0>()
        if (size != 16) {
            throw Exception("Size of Fixed16_open0_16_close0_Fixed16_open0_16_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<Fixed16_open0_16_close0_Fixed16_open0_16_close0>()
        if (align != 1) {
            throw Exception("Alignment of Fixed16_open0_16_close0_Fixed16_open0_16_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct FixedArray_open0_8_close0_FixedArray_open0_8_close0 {
    let _cjbind_opaque_blob: VArray<UInt8, $8>
    public func clone(): FixedArray_open0_8_close0_FixedArray_open0_8_close0 {
        return this
    }
    public func toString(): String {
        var output = "FixedArray_open0_8_close0_FixedArray_open0_8_close0 {"
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
        let size = sizeOf<FixedArray_open0_8_close0_FixedArray_open0_8_close0>()
        if (size != 8) {
            throw Exception("Size of FixedArray_open0_8_close0_FixedArray_open0_8_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<FixedArray_open0_8_close0_FixedArray_open0_8_close0>()
        if (align != 1) {
            throw Exception(
                "Alignment of FixedArray_open0_8_close0_FixedArray_open0_8_close0 is not 1 but ${align} bytes")
        }
}

@C
public struct PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0 {
    public let first: Bool
    public let second: Int32
    public func clone(): PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0 {"
        output += " first: "
        output += this.first.toString()
        output += ", second: "
        output += this.second.toString()
        output += " }"
        return output
    }
    public init(first: Bool, second: Int32) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0>()
        if (size != 8) {
            throw Exception(
                "Size of PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasHolder_AliasHolder {
    public let chars: Fixed16_open0_16_close0_Fixed16_open0_16_close0
    public let flags: FixedArray_open0_8_close0_FixedArray_open0_8_close0
    public let integers: FixedArray_open0_4_close0_FixedArray_open0_4_close0
    public let defaulted: PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0
    public func clone(): AliasHolder_AliasHolder {
        return this
    }
    public func toString(): String {
        var output = "AliasHolder_AliasHolder {"
        output += " chars: "
        output += this.chars.toString()
        output += ", flags: "
        output += this.flags.toString()
        output += ", integers: "
        output += this.integers.toString()
        output += ", defaulted: "
        output += this.defaulted.toString()
        output += " }"
        return output
    }
    public init(chars: Fixed16_open0_16_close0_Fixed16_open0_16_close0,
        flags: FixedArray_open0_8_close0_FixedArray_open0_8_close0,
        integers: FixedArray_open0_4_close0_FixedArray_open0_4_close0,
        defaulted: PairWithDefault_open0_bool_int_close0_PairWithDefault_open0_bool_int_close0) {
        this.chars = chars
        this.flags = flags
        this.integers = integers
        this.defaulted = defaulted
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasHolder_AliasHolder>()
        if (size != 48) {
            throw Exception("Size of AliasHolder_AliasHolder is not 48 but ${size} bytes")
        }
        let align = alignOf<AliasHolder_AliasHolder>()
        if (align != 4) {
            throw Exception("Alignment of AliasHolder_AliasHolder is not 4 but ${align} bytes")
        }
}
