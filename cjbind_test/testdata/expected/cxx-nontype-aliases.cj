package cjbind_ffi

public type Fixed16 = UInt8

public type FixedInts = VArray<UInt32, $4>

@C
public struct AliasHolder {
    public let chars: VArray<UInt8, $16>
    public let flags: VArray<UInt8, $8>
    public let integers: FixedInts
    public let defaulted: PairWithDefault_open0_bool_int_close0
    public init(chars: VArray<UInt8, $16>, flags: VArray<UInt8, $8>, integers: FixedInts,
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
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $2>>() }
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
