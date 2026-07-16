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
public struct FullWordWidth {
    var _bitfield_1: UInt64 = unsafe { zeroValue<UInt64>() }
    public mut prop full: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 64) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 64, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt64, $0> = unsafe { zeroValue<VArray<UInt64, $0>>() }
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
    var _bitfield_1: UInt64 = unsafe { zeroValue<UInt64>() }
    public mut prop first: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 1, UInt64(value)) }
        }
    }
    public mut prop rest: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 1, 63) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 1, 63, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt64, $0> = unsafe { zeroValue<VArray<UInt64, $0>>() }
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
