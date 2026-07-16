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
public struct timex {
    public var tai: Int32 = unsafe { zeroValue<Int32>() }
    var _bitfield_1: VArray<UInt8, $44> = unsafe { zeroValue<VArray<UInt8, $44>>() }
    let _cjbind_bitfield_alignment_marker: VArray<UInt32, $0> = unsafe { zeroValue<VArray<UInt32, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<timex>()
        if (size != 48) {
            throw Exception("Size of timex is not 48 but ${size} bytes")
        }
        let align = alignOf<timex>()
        if (align != 4) {
            throw Exception("Alignment of timex is not 4 but ${align} bytes")
        }
}

@C
public struct timex_named {
    public var tai: Int32 = unsafe { zeroValue<Int32>() }
    var _bitfield_1: VArray<UInt32, $11> = unsafe { zeroValue<VArray<UInt32, $11>>() }
    public mut prop a: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 0, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop b: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 32, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 32, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop c: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 64, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 64, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop d: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 96, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 96, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop e: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 128, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 128, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop f: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 160, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 160, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop g: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 192, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 192, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop h: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 224, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 224, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop i: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 256, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 256, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop j: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 288, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 288, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    public mut prop k: Int32 {
        get() {
            var s = this._bitfield_1
            return Int32(unsafe { __cjbind_bitfield_read_signed(CPointer<UInt8>(inout s), 320, 32) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 320, 32,
                __cjbind_bitfield_int64_to_uint64(Int64(value))) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt32, $0> = unsafe { zeroValue<VArray<UInt32, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<timex_named>()
        if (size != 48) {
            throw Exception("Size of timex_named is not 48 but ${size} bytes")
        }
        let align = alignOf<timex_named>()
        if (align != 4) {
            throw Exception("Alignment of timex_named is not 4 but ${align} bytes")
        }
}
