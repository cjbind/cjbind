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
public struct FullWordWidth {
    var _bitfield_1: VArray<UInt8, $8> = VArray<UInt8, $8>(repeat: 0)
    public func full(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 0, 64) })
    }
    public mut func full(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 64, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FullWordWidth>()
        if (size != 8) {
            throw Exception("Size of FullWordWidth is not 8 but ${size} bytes")
        }
        let align = alignOf<FullWordWidth>()
        if (align != 8) {
            throw Exception("Alignment of FullWordWidth is not 8 but ${align} bytes")
        }
}

@C
public struct ShiftedWordWidth {
    var _bitfield_1: VArray<UInt8, $8> = VArray<UInt8, $8>(repeat: 0)
    public func first(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 0, 1) })
    }
    public mut func first(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
    }
    public func rest(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 1, 63) })
    }
    public mut func rest(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 63, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ShiftedWordWidth>()
        if (size != 8) {
            throw Exception("Size of ShiftedWordWidth is not 8 but ${size} bytes")
        }
        let align = alignOf<ShiftedWordWidth>()
        if (align != 8) {
            throw Exception("Alignment of ShiftedWordWidth is not 8 but ${align} bytes")
        }
}
