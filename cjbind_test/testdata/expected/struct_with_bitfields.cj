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
        return Int64(raw | !((UInt64(1) << UInt64(bitWidth)) - 1))
    }
    return Int64(raw)
}

@C
public struct bitfield {
    var _bitfield_1: VArray<UInt8, $1> = VArray<UInt8, $1>(repeat: 0)
    public func a(): UInt16 {
        var s = this._bitfield_1
        return UInt16(unsafe { __cjbind_bitfield_read(inout s, 0, 1) })
    }
    public mut func a(val!: UInt16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
    }
    public func b(): UInt16 {
        var s = this._bitfield_1
        return UInt16(unsafe { __cjbind_bitfield_read(inout s, 1, 1) })
    }
    public mut func b(val!: UInt16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 1, UInt64(val)) }
    }
    public func c(): UInt16 {
        var s = this._bitfield_1
        return UInt16(unsafe { __cjbind_bitfield_read(inout s, 2, 1) })
    }
    public mut func c(val!: UInt16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 2, 1, UInt64(val)) }
    }
    public func d(): UInt16 {
        var s = this._bitfield_1
        return UInt16(unsafe { __cjbind_bitfield_read(inout s, 6, 2) })
    }
    public mut func d(val!: UInt16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 6, 2, UInt64(val)) }
    }
    public var e: Int32 = unsafe { zeroValue<Int32>() }
    var _bitfield_2: VArray<UInt8, $8> = VArray<UInt8, $8>(repeat: 0)
    public func f(): UInt32 {
        var s = this._bitfield_2
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 0, 2) })
    }
    public mut func f(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 0, 2, UInt64(val)) }
    }
    public func g(): UInt32 {
        var s = this._bitfield_2
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 32, 32) })
    }
    public mut func g(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 32, 32, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bitfield>()
        if (size != 16) {
            throw Exception("Size of bitfield is not 16 but ${size} bytes")
        }
        let align = alignOf<bitfield>()
        if (align != 4) {
            throw Exception("Alignment of bitfield is not 4 but ${align} bytes")
        }
}

@C
public struct MixedPtrBoolBitfield {
    public var p: CPointer<Unit> = unsafe { zeroValue<CPointer<Unit>>() }
    public var b: Bool = unsafe { zeroValue<Bool>() }
    var _bitfield_1: VArray<UInt8, $2> = VArray<UInt8, $2>(repeat: 0)
    public func u(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 0, 16) })
    }
    public mut func u(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 16, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MixedPtrBoolBitfield>()
        if (size != 16) {
            throw Exception("Size of MixedPtrBoolBitfield is not 16 but ${size} bytes")
        }
        let align = alignOf<MixedPtrBoolBitfield>()
        if (align != 8) {
            throw Exception("Alignment of MixedPtrBoolBitfield is not 8 but ${align} bytes")
        }
}

@C
public struct OnlyUnnamedBitfield {
    var _bitfield_1: VArray<UInt8, $2> = VArray<UInt8, $2>(repeat: 0)
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<OnlyUnnamedBitfield>()
        if (size != 2) {
            throw Exception("Size of OnlyUnnamedBitfield is not 2 but ${size} bytes")
        }
        let align = alignOf<OnlyUnnamedBitfield>()
        if (align != 1) {
            throw Exception("Alignment of OnlyUnnamedBitfield is not 1 but ${align} bytes")
        }
}

@C
public struct MixedSignedUnnamedBitfield {
    var _bitfield_1: VArray<UInt8, $3> = VArray<UInt8, $3>(repeat: 0)
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MixedSignedUnnamedBitfield>()
        if (size != 3) {
            throw Exception("Size of MixedSignedUnnamedBitfield is not 3 but ${size} bytes")
        }
        let align = alignOf<MixedSignedUnnamedBitfield>()
        if (align != 1) {
            throw Exception("Alignment of MixedSignedUnnamedBitfield is not 1 but ${align} bytes")
        }
}

public type U8 = UInt8

public type U16 = UInt16

@C
public struct V56AMDY {
    var _bitfield_1: VArray<UInt8, $2> = VArray<UInt8, $2>(repeat: 0)
    public func MADZ(): U16 {
        var s = this._bitfield_1
        return U16(unsafe { __cjbind_bitfield_read(inout s, 0, 10) })
    }
    public mut func MADZ(val!: U16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 10, UInt64(val)) }
    }
    public func MAI0(): U16 {
        var s = this._bitfield_1
        return U16(unsafe { __cjbind_bitfield_read(inout s, 10, 2) })
    }
    public mut func MAI0(val!: U16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 10, 2, UInt64(val)) }
    }
    public func MAI1(): U16 {
        var s = this._bitfield_1
        return U16(unsafe { __cjbind_bitfield_read(inout s, 12, 2) })
    }
    public mut func MAI1(val!: U16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 12, 2, UInt64(val)) }
    }
    public func MAI2(): U16 {
        var s = this._bitfield_1
        return U16(unsafe { __cjbind_bitfield_read(inout s, 14, 2) })
    }
    public mut func MAI2(val!: U16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 14, 2, UInt64(val)) }
    }
    public var MADK: U8 = unsafe { zeroValue<U8>() }
    public var MABR: U8 = unsafe { zeroValue<U8>() }
    var _bitfield_2: VArray<UInt8, $3> = VArray<UInt8, $3>(repeat: 0)
    public func MATH(): U16 {
        var s = this._bitfield_2
        return U16(unsafe { __cjbind_bitfield_read(inout s, 0, 10) })
    }
    public mut func MATH(val!: U16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 0, 10, UInt64(val)) }
    }
    public func MATE(): U16 {
        var s = this._bitfield_2
        return U16(unsafe { __cjbind_bitfield_read(inout s, 10, 4) })
    }
    public mut func MATE(val!: U16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 10, 4, UInt64(val)) }
    }
    public func MATW(): U16 {
        var s = this._bitfield_2
        return U16(unsafe { __cjbind_bitfield_read(inout s, 14, 2) })
    }
    public mut func MATW(val!: U16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 14, 2, UInt64(val)) }
    }
    public func MASW(): U8 {
        var s = this._bitfield_2
        return U8(unsafe { __cjbind_bitfield_read(inout s, 16, 4) })
    }
    public mut func MASW(val!: U8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 16, 4, UInt64(val)) }
    }
    public func MABW(): U8 {
        var s = this._bitfield_2
        return U8(unsafe { __cjbind_bitfield_read(inout s, 20, 3) })
    }
    public mut func MABW(val!: U8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 20, 3, UInt64(val)) }
    }
    public func MAXN(): U8 {
        var s = this._bitfield_2
        return U8(unsafe { __cjbind_bitfield_read(inout s, 23, 1) })
    }
    public mut func MAXN(val!: U8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 23, 1, UInt64(val)) }
    }
    public var _rB_: U8 = unsafe { zeroValue<U8>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<V56AMDY>()
        if (size != 8) {
            throw Exception("Size of V56AMDY is not 8 but ${size} bytes")
        }
        let align = alignOf<V56AMDY>()
        if (align != 2) {
            throw Exception("Alignment of V56AMDY is not 2 but ${align} bytes")
        }
}
