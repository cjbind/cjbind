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
public struct A_A {
public var name : VArray<UInt8, $7> = unsafe { zeroValue<VArray<UInt8, $7>>() }
var _bitfield_1 : VArray<UInt8, $4> = VArray<UInt8, $4>(repeat: 0)
public func firmness(): UInt8 {
    var s = this._bitfield_1
    return UInt8(unsafe { __cjbind_bitfield_read(inout s, 0, 4) })
}
public mut func firmness(val!: UInt8): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 4, UInt64(val)) }
}
public func color(): UInt8 {
    var s = this._bitfield_1
    return UInt8(unsafe { __cjbind_bitfield_read(inout s, 4, 4) })
}
public mut func color(val!: UInt8): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 4, 4, UInt64(val)) }
}
public func weedsBonus(): UInt16 {
    var s = this._bitfield_1
    return UInt16(unsafe { __cjbind_bitfield_read(inout s, 8, 3) })
}
public mut func weedsBonus(val!: UInt16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 8, 3, UInt64(val)) }
}
public func pestsBonus(): UInt16 {
    var s = this._bitfield_1
    return UInt16(unsafe { __cjbind_bitfield_read(inout s, 11, 3) })
}
public mut func pestsBonus(val!: UInt16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 11, 3, UInt64(val)) }
}
public func size(): UInt16 {
    var s = this._bitfield_1
    return UInt16(unsafe { __cjbind_bitfield_read(inout s, 16, 10) })
}
public mut func size(val!: UInt16): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 16, 10, UInt64(val)) }
}
public var maxYield : UInt8 = unsafe { zeroValue<UInt8>() }
var _bitfield_2 : VArray<UInt8, $1> = VArray<UInt8, $1>(repeat: 0)
public func minYield(): UInt8 {
    var s = this._bitfield_2
    return UInt8(unsafe { __cjbind_bitfield_read(inout s, 0, 4) })
}
public mut func minYield(val!: UInt8): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 0, 4, UInt64(val)) }
}
public func waterBonus(): UInt8 {
    var s = this._bitfield_2
    return UInt8(unsafe { __cjbind_bitfield_read(inout s, 4, 4) })
}
public mut func waterBonus(val!: UInt8): Unit {
    unsafe { __cjbind_bitfield_write(inout this._bitfield_2, 4, 4, UInt64(val)) }
}
public var description1 : CPointer<UInt8> = unsafe { zeroValue<CPointer<UInt8>>() }
public init() {}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<A_A>()
    if (size != 24) {
        throw Exception("Size of A_A is not 24 but ${size} bytes")
    }
    let align = alignOf<A_A>()
    if (align != 8) {
        throw Exception("Alignment of A_A is not 8 but ${align} bytes")
    }
}