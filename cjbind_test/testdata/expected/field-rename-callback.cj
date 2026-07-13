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
public struct RenameMe_RenameMe {
    public var plain: Int32 = unsafe { zeroValue<Int32>() }
    public var cj_friendly: Int32 = unsafe { zeroValue<Int32>() }
    var _bitfield_1: VArray<UInt8, $1> = VArray<UInt8, $1>(repeat: 0)
    public func bitfield_less_ugly_name(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 0, 1) })
    }
    public mut func bitfield_less_ugly_name(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
    }
    public func bitfield_better_name(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 1, 1) })
    }
    public mut func bitfield_better_name(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 1, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RenameMe_RenameMe>()
        if (size != 12) {
            throw Exception("Size of RenameMe_RenameMe is not 12 but ${size} bytes")
        }
        let align = alignOf<RenameMe_RenameMe>()
        if (align != 4) {
            throw Exception("Alignment of RenameMe_RenameMe is not 4 but ${align} bytes")
        }
}
