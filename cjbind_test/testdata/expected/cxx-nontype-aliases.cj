package cjbind_ffi

public type FixedInts_FixedInts = VArray<UInt32, $4>

@C
public struct AliasHolder_PairWithDefault_open0_bool_close0_PairWithDefault_open0_bool_close0 {
    public let first: Bool
    public let second: Int32
    public init(first: Bool, second: Int32) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasHolder_PairWithDefault_open0_bool_close0_PairWithDefault_open0_bool_close0>()
        if (size != 8) {
            throw Exception(
                "Size of AliasHolder_PairWithDefault_open0_bool_close0_PairWithDefault_open0_bool_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<AliasHolder_PairWithDefault_open0_bool_close0_PairWithDefault_open0_bool_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of AliasHolder_PairWithDefault_open0_bool_close0_PairWithDefault_open0_bool_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct AliasHolder_AliasHolder {
    public let chars: VArray<UInt8, $16>
    public let flags: VArray<UInt8, $8>
    public let integers: VArray<UInt32, $4>
    public let defaulted: AliasHolder_PairWithDefault_open0_bool_close0_PairWithDefault_open0_bool_close0
    public init(chars: VArray<UInt8, $16>, flags: VArray<UInt8, $8>, integers: VArray<UInt32, $4>,
        defaulted: AliasHolder_PairWithDefault_open0_bool_close0_PairWithDefault_open0_bool_close0) {
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
