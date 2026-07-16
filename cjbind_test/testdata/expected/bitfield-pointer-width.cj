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

public const POINTER_WIDTH: UInt64 = 64

@C
public struct Foo {
    var _bitfield_1: VArray<UInt64, $4> = unsafe { zeroValue<VArray<UInt64, $4>>() }
    public mut prop m_bitfield: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 64) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 64, UInt64(value)) }
        }
    }
    public mut prop m_bar: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 64, 64) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 64, 64, UInt64(value)) }
        }
    }
    public mut prop foo: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 128, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 128, 1, UInt64(value)) }
        }
    }
    public mut prop bar: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 192, 64) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 192, 64, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt64, $0> = unsafe { zeroValue<VArray<UInt64, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Foo>()
        if (size != 32) {
            throw Exception("Size of Foo is not 32 but ${size} bytes")
        }
        let align = alignOf<Foo>()
        if (align != 8) {
            throw Exception("Alignment of Foo is not 8 but ${align} bytes")
        }
}
