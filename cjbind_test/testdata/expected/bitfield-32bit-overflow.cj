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
public struct MuchBitfield {
    var _bitfield_1: VArray<UInt8, $5> = unsafe { zeroValue<VArray<UInt8, $5>>() }
    public mut prop m0: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 0, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m1: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 1, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 1, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m2: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 2, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 2, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m3: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 3, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 3, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m4: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 4, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 4, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m5: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 5, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 5, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m6: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 6, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 6, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m7: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 7, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 7, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m8: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 8, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 8, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m9: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 9, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 9, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m10: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 10, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 10, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m11: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 11, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 11, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m12: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 12, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 12, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m13: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 13, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 13, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m14: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 14, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 14, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m15: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 15, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 15, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m16: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 16, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 16, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m17: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 17, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 17, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m18: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 18, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 18, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m19: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 19, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 19, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m20: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 20, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 20, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m21: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 21, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 21, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m22: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 22, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 22, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m23: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 23, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 23, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m24: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 24, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 24, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m25: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 25, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 25, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m26: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 26, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 26, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m27: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 27, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 27, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m28: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 28, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 28, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m29: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 29, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 29, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m30: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 30, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 30, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m31: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 31, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 31, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop m32: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 32, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 32, 1,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MuchBitfield>()
        if (size != 5) {
            throw Exception("Size of MuchBitfield is not 5 but ${size} bytes")
        }
        let align = alignOf<MuchBitfield>()
        if (align != 1) {
            throw Exception("Alignment of MuchBitfield is not 1 but ${align} bytes")
        }
}

@C
public struct capabilities {
    var _bitfield_1: VArray<UInt32, $4> = unsafe { zeroValue<VArray<UInt32, $4>>() }
    public mut prop bit_1: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 1, UInt64(value)) }
        }
    }
    public mut prop bit_2: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 1, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 1, 1, UInt64(value)) }
        }
    }
    public mut prop bit_3: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 2, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 2, 1, UInt64(value)) }
        }
    }
    public mut prop bit_4: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 3, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 3, 1, UInt64(value)) }
        }
    }
    public mut prop bit_5: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 4, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 4, 1, UInt64(value)) }
        }
    }
    public mut prop bit_6: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 5, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 5, 1, UInt64(value)) }
        }
    }
    public mut prop bit_7: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 6, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 6, 1, UInt64(value)) }
        }
    }
    public mut prop bit_8: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 7, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 7, 1, UInt64(value)) }
        }
    }
    public mut prop bit_9: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 8, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 8, 1, UInt64(value)) }
        }
    }
    public mut prop bit_10: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 9, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 9, 1, UInt64(value)) }
        }
    }
    public mut prop bit_11: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 10, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 10, 1, UInt64(value)) }
        }
    }
    public mut prop bit_12: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 11, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 11, 1, UInt64(value)) }
        }
    }
    public mut prop bit_13: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 12, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 12, 1, UInt64(value)) }
        }
    }
    public mut prop bit_14: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 13, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 13, 1, UInt64(value)) }
        }
    }
    public mut prop bit_15: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 14, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 14, 1, UInt64(value)) }
        }
    }
    public mut prop bit_16: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 15, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 15, 1, UInt64(value)) }
        }
    }
    public mut prop bit_17: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 16, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 16, 1, UInt64(value)) }
        }
    }
    public mut prop bit_18: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 17, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 17, 1, UInt64(value)) }
        }
    }
    public mut prop bit_19: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 18, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 18, 1, UInt64(value)) }
        }
    }
    public mut prop bit_20: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 19, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 19, 1, UInt64(value)) }
        }
    }
    public mut prop bit_21: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 20, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 20, 1, UInt64(value)) }
        }
    }
    public mut prop bit_22: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 21, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 21, 1, UInt64(value)) }
        }
    }
    public mut prop bit_23: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 22, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 22, 1, UInt64(value)) }
        }
    }
    public mut prop bit_24: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 23, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 23, 1, UInt64(value)) }
        }
    }
    public mut prop bit_25: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 24, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 24, 1, UInt64(value)) }
        }
    }
    public mut prop bit_26: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 25, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 25, 1, UInt64(value)) }
        }
    }
    public mut prop bit_27: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 26, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 26, 1, UInt64(value)) }
        }
    }
    public mut prop bit_28: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 27, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 27, 1, UInt64(value)) }
        }
    }
    public mut prop bit_29: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 28, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 28, 1, UInt64(value)) }
        }
    }
    public mut prop bit_30: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 29, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 29, 1, UInt64(value)) }
        }
    }
    public mut prop bit_31: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 30, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 30, 1, UInt64(value)) }
        }
    }
    public mut prop bit_32: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 31, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 31, 1, UInt64(value)) }
        }
    }
    public mut prop bit_33: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 32, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 32, 1, UInt64(value)) }
        }
    }
    public mut prop bit_34: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 33, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 33, 1, UInt64(value)) }
        }
    }
    public mut prop bit_35: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 34, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 34, 1, UInt64(value)) }
        }
    }
    public mut prop bit_36: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 35, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 35, 1, UInt64(value)) }
        }
    }
    public mut prop bit_37: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 36, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 36, 1, UInt64(value)) }
        }
    }
    public mut prop bit_38: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 37, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 37, 1, UInt64(value)) }
        }
    }
    public mut prop bit_39: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 38, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 38, 1, UInt64(value)) }
        }
    }
    public mut prop bit_40: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 39, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 39, 1, UInt64(value)) }
        }
    }
    public mut prop bit_41: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 40, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 40, 1, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt32, $0> = unsafe { zeroValue<VArray<UInt32, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<capabilities>()
        if (size != 16) {
            throw Exception("Size of capabilities is not 16 but ${size} bytes")
        }
        let align = alignOf<capabilities>()
        if (align != 4) {
            throw Exception("Alignment of capabilities is not 4 but ${align} bytes")
        }
}
