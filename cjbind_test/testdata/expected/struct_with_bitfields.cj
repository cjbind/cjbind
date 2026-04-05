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
    var fieldMask: UInt64 = if (bitWidth < 64) {
        ((UInt64(1) << UInt64(bitWidth)) - 1) << UInt64(bitShift)
    } else {
        !UInt64(0)
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
    let raw = __cjbind_bitfield_read(ptr, bitOffset, bitWidth)
    if (bitWidth > 0 && bitWidth < 64 && (raw & (UInt64(1) << UInt64(bitWidth - 1))) != 0) {
        return Int64(raw | !((UInt64(1) << UInt64(bitWidth)) - 1))
    }
    return Int64(raw)
}

package cjbind_ffi

@C
public struct bitfield_bitfield {
let _cjbind_opaque_blob: VArray<UInt32, $4>
public init() {
    this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $4>>() }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<bitfield_bitfield>()
    if (size != 16) {
        throw Exception("Size of bitfield_bitfield is not 16 but ${size} bytes")
    }
    let align = alignOf<bitfield_bitfield>()
    if (align != 4) {
        throw Exception("Alignment of bitfield_bitfield is not 4 but ${align} bytes")
    }
}

@C
public struct MixedPtrBoolBitfield_MixedPtrBoolBitfield {
public var p : CPointer<Unit> = unsafe { zeroValue<CPointer<Unit>>() }
public var b : Bool = unsafe { zeroValue<Bool>() }
var _bitfield_1 : VArray<UInt8, $2> = VArray<UInt8, $2>(repeat: 0)
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
    let size = sizeOf<MixedPtrBoolBitfield_MixedPtrBoolBitfield>()
    if (size != 16) {
        throw Exception("Size of MixedPtrBoolBitfield_MixedPtrBoolBitfield is not 16 but ${size} bytes")
    }
    let align = alignOf<MixedPtrBoolBitfield_MixedPtrBoolBitfield>()
    if (align != 8) {
        throw Exception("Alignment of MixedPtrBoolBitfield_MixedPtrBoolBitfield is not 8 but ${align} bytes")
    }
}

@C
public struct OnlyUnnamedBitfield_OnlyUnnamedBitfield {
var _bitfield_1 : VArray<UInt8, $2> = VArray<UInt8, $2>(repeat: 0)
public init() {}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<OnlyUnnamedBitfield_OnlyUnnamedBitfield>()
    if (size != 4) {
        throw Exception("Size of OnlyUnnamedBitfield_OnlyUnnamedBitfield is not 4 but ${size} bytes")
    }
    let align = alignOf<OnlyUnnamedBitfield_OnlyUnnamedBitfield>()
    if (align != 4) {
        throw Exception("Alignment of OnlyUnnamedBitfield_OnlyUnnamedBitfield is not 4 but ${align} bytes")
    }
}

@C
public struct MixedSignedUnnamedBitfield_MixedSignedUnnamedBitfield {
var _bitfield_1 : VArray<UInt8, $3> = VArray<UInt8, $3>(repeat: 0)
public init() {}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<MixedSignedUnnamedBitfield_MixedSignedUnnamedBitfield>()
    if (size != 4) {
        throw Exception("Size of MixedSignedUnnamedBitfield_MixedSignedUnnamedBitfield is not 4 but ${size} bytes")
    }
    let align = alignOf<MixedSignedUnnamedBitfield_MixedSignedUnnamedBitfield>()
    if (align != 4) {
        throw Exception("Alignment of MixedSignedUnnamedBitfield_MixedSignedUnnamedBitfield is not 4 but ${align} bytes")
    }
}

public type U8_U8 = UInt8

public type U16_U16 = UInt16

@C
public struct V56AMDY_V56AMDY {
var _bitfield_1 : VArray<UInt8, $2> = VArray<UInt8, $2>(repeat: 0)
public func MADZ(): U16_U16 {
    var s = this._bitfield_1
    return U16_U16(unsafe { __cjbind_bitfield_read(inout s, 0, 10) })
}
public mut func MADZ(val!: U16_U16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 10, UInt64(val)) }
}
public func MAI0(): U16_U16 {
    var s = this._bitfield_1
    return U16_U16(unsafe { __cjbind_bitfield_read(inout s, 10, 2) })
}
public mut func MAI0(val!: U16_U16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 10, 2, UInt64(val)) }
}
public func MAI1(): U16_U16 {
    var s = this._bitfield_1
    return U16_U16(unsafe { __cjbind_bitfield_read(inout s, 12, 2) })
}
public mut func MAI1(val!: U16_U16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 12, 2, UInt64(val)) }
}
public func MAI2(): U16_U16 {
    var s = this._bitfield_1
    return U16_U16(unsafe { __cjbind_bitfield_read(inout s, 14, 2) })
}
public mut func MAI2(val!: U16_U16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 14, 2, UInt64(val)) }
}
public var MADK : U8_U8 = unsafe { zeroValue<U8_U8>() }
public var MABR : U8_U8 = unsafe { zeroValue<U8_U8>() }
var _bitfield_2 : VArray<UInt8, $3> = VArray<UInt8, $3>(repeat: 0)
public func MATH(): U16_U16 {
    var s = this._bitfield_2
    return U16_U16(unsafe { __cjbind_bitfield_read(inout s, 0, 10) })
}
public mut func MATH(val!: U16_U16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 0, 10, UInt64(val)) }
}
public func MATE(): U16_U16 {
    var s = this._bitfield_2
    return U16_U16(unsafe { __cjbind_bitfield_read(inout s, 10, 4) })
}
public mut func MATE(val!: U16_U16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 10, 4, UInt64(val)) }
}
public func MATW(): U16_U16 {
    var s = this._bitfield_2
    return U16_U16(unsafe { __cjbind_bitfield_read(inout s, 14, 2) })
}
public mut func MATW(val!: U16_U16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 14, 2, UInt64(val)) }
}
public func MASW(): U8_U8 {
    var s = this._bitfield_2
    return U8_U8(unsafe { __cjbind_bitfield_read(inout s, 16, 4) })
}
public mut func MASW(val!: U8_U8): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 16, 4, UInt64(val)) }
}
public func MABW(): U8_U8 {
    var s = this._bitfield_2
    return U8_U8(unsafe { __cjbind_bitfield_read(inout s, 20, 3) })
}
public mut func MABW(val!: U8_U8): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 20, 3, UInt64(val)) }
}
public func MAXN(): U8_U8 {
    var s = this._bitfield_2
    return U8_U8(unsafe { __cjbind_bitfield_read(inout s, 23, 1) })
}
public mut func MAXN(val!: U8_U8): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 23, 1, UInt64(val)) }
}
public var _rB_ : U8_U8 = unsafe { zeroValue<U8_U8>() }
public init() {}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<V56AMDY_V56AMDY>()
    if (size != 8) {
        throw Exception("Size of V56AMDY_V56AMDY is not 8 but ${size} bytes")
    }
    let align = alignOf<V56AMDY_V56AMDY>()
    if (align != 2) {
        throw Exception("Alignment of V56AMDY_V56AMDY is not 2 but ${align} bytes")
    }
}