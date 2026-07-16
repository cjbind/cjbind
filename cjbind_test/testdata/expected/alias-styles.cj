package cjbind_ffi

@C
func __cjbind_bitfield_read(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): UInt64 {
    let startByte = bitOffset / 8
    let bitShift = bitOffset % 8
    let bytesNeeded = (bitWidth + bitShift + 7) / 8
    var val: UInt64 = 0
    var i: Int64 = 0
    while (i < bytesNeeded) {
        val = val | (UInt64(unsafe { ptr.read(startByte + i) }) << UInt64(i * 8))
        i++
    }
    val = val >> UInt64(bitShift)
    if (bitWidth < 64) {
        val = val & ((UInt64(1) << UInt64(bitWidth)) - 1)
    }
    return val
}

@C
func __cjbind_bitfield_write(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64, val: UInt64): Unit {
    let startByte = bitOffset / 8
    let bitShift = bitOffset % 8
    let bytesNeeded = (bitWidth + bitShift + 7) / 8
    var maskVal = val
    if (bitWidth < 64) {
        maskVal = maskVal & ((UInt64(1) << UInt64(bitWidth)) - 1)
    }
    maskVal = maskVal << UInt64(bitShift)
    var fieldMask: UInt64 = if (bitWidth + bitShift < 64) {
        ((UInt64(1) << UInt64(bitWidth)) - 1) << UInt64(bitShift)
    } else {
        !UInt64(0) << UInt64(bitShift)
    }
    var i: Int64 = 0
    while (i < bytesNeeded) {
        let byteVal = UInt8((maskVal >> UInt64(i * 8)) & 0xFF)
        let byteMask = UInt8((fieldMask >> UInt64(i * 8)) & 0xFF)
        let old = unsafe { ptr.read(startByte + i) }
        unsafe { ptr.write(startByte + i, (old & !byteMask) | (byteVal & byteMask)) }
        i++
    }
}

@C
func __cjbind_bitfield_read_signed(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): Int64 {
    let raw = unsafe { __cjbind_bitfield_read(ptr, bitOffset, bitWidth) }
    if (bitWidth > 0 && bitWidth < 64 && (raw & (UInt64(1) << UInt64(bitWidth - 1))) != 0) {
        let extended = raw | !((UInt64(1) << UInt64(bitWidth)) - 1)
        return unsafe { __cjbind_bitfield_uint64_to_int64(extended) }
    }
    return unsafe { __cjbind_bitfield_uint64_to_int64(raw) }
}

@C
func __cjbind_bitfield_int64_to_uint64(value: Int64): UInt64 {
    var copy = value
    return unsafe { CPointer<UInt64>(CPointer<Int64>(inout copy)).read() }
}

@C
func __cjbind_bitfield_uint64_to_int64(value: UInt64): Int64 {
    var copy = value
    return unsafe { CPointer<Int64>(CPointer<UInt64>(inout copy)).read() }
}

@C
public struct DefaultStrongAlias {
    public var rawValue: Int32

    public init(rawValue!: Int32) {
        this.rawValue = rawValue
    }
}

public type PlainAlias = Int32

@C
public struct StrongAlias {
    public var rawValue: UInt32

    public init(rawValue!: UInt32) {
        this.rawValue = rawValue
    }
}

@C
public struct AccessibleAlias {
    public var rawValue: Int64

    public init(rawValue!: Int64) {
        this.rawValue = rawValue
    }

    public mut prop value: Int64 {
        get() {
            return this.rawValue
        }
        set(value) {
            this.rawValue = value
        }
    }

    public static func wrap(rawValue: Int64): AccessibleAlias {
        return AccessibleAlias(rawValue: rawValue)
    }

    public func unwrap(): Int64 {
        return this.rawValue
    }
}

@C
public struct FloatAlias {
    public var rawValue: Float32

    public init(rawValue!: Float32) {
        this.rawValue = rawValue
    }
}

public type VoidAlias = Unit

public const PLAIN_ALIAS_CONST: PlainAlias = -3
public let STRONG_ALIAS_CONST: StrongAlias = StrongAlias(rawValue: 5)
public let ACCESSIBLE_ALIAS_CONST: AccessibleAlias = AccessibleAlias(rawValue: -7)
public let FLOAT_ALIAS_CONST: FloatAlias = FloatAlias(rawValue: 1.500000)

public type AliasCallback = CFunc<(strong: UInt32, accessible: Int64, pointer: CPointer<StrongAlias>) -> Int64>

@C
public struct AliasMode {
    public var rawValue: UInt32 = unsafe { zeroValue<UInt32>() }
    public init(rawValue!: UInt32) {
        this.rawValue = rawValue
    }
    public static let ALIAS_MODE_ZERO = AliasMode(rawValue: 0)
    public static let ALIAS_MODE_ONE = AliasMode(rawValue: 1)
    public static let ALIAS_MODE_TWO = AliasMode(rawValue: 2)
    public operator func ==(right: AliasMode): Bool {
        this.rawValue == right.rawValue
    }
    public operator func !=(right: AliasMode): Bool {
        this.rawValue != right.rawValue
    }
}

@C
public struct AliasModeAlias {
    public var rawValue: AliasMode

    public init(rawValue!: AliasMode) {
        this.rawValue = rawValue
    }
}

public type AliasModeCallback = CFunc<(value: UInt32) -> UInt32>

foreign func alias_mode_round_trip(value: UInt32): UInt32

public unsafe func alias_mode_round_trip_cjbindwrapper(value: AliasMode): AliasMode {
    return AliasMode(rawValue: alias_mode_round_trip(value.rawValue))
}

foreign func alias_mode_alias_round_trip(value: UInt32): UInt32

public unsafe func alias_mode_alias_round_trip_cjbindwrapper(value: AliasModeAlias): AliasModeAlias {
    return AliasModeAlias(rawValue: AliasMode(rawValue: alias_mode_alias_round_trip(value.rawValue.rawValue)))
}

@C
public struct AliasBits {
    var _bitfield_1: UInt64 = unsafe { zeroValue<UInt64>() }
    public mut prop strong: StrongAlias {
        get() {
            var s = this._bitfield_1
            return StrongAlias(rawValue: UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 3) }))
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 3, UInt64(value.rawValue)) }
        }
    }
    public mut prop accessible: AccessibleAlias {
        get() {
            var s = this._bitfield_1
            return AccessibleAlias(
                rawValue: Int64(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 3, 5) }))
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 3, 5,
                __cjbind_bitfield_int64_to_uint64(Int64(value.rawValue))) }
        }
    }
    public mut prop plain: PlainAlias {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 8, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 8, 4,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop mode: AliasMode {
        get() {
            var s = this._bitfield_1
            return AliasMode(rawValue: UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 12, 2) }))
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 12, 2, UInt64(value.rawValue)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt64, $0> = unsafe { zeroValue<VArray<UInt64, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AliasBits>()
        if (size != 8) {
            throw Exception("Size of AliasBits is not 8 but ${size} bytes")
        }
        let align = alignOf<AliasBits>()
        if (align != 8) {
            throw Exception("Alignment of AliasBits is not 8 but ${align} bytes")
        }
}

foreign func alias_round_trip(plain: PlainAlias, strong: UInt32, accessible: Int64): Int32

public unsafe func alias_round_trip_cjbindwrapper(plain: PlainAlias, strong: StrongAlias, accessible: AccessibleAlias): DefaultStrongAlias {
    return DefaultStrongAlias(rawValue: alias_round_trip(plain, strong.rawValue, accessible.rawValue))
}

foreign func float_alias_round_trip(value: Float32): Float32

public unsafe func float_alias_round_trip_cjbindwrapper(value: FloatAlias): FloatAlias {
    return FloatAlias(rawValue: float_alias_round_trip(value.rawValue))
}

foreign func update_strong_alias(value: CPointer<StrongAlias>): Unit
