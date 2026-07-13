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
public struct timex_timex {
    public var tai: Int32 = unsafe { zeroValue<Int32>() }
    var _bitfield_1: VArray<UInt8, $44> = VArray<UInt8, $44>(repeat: 0)
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<timex_timex>()
        if (size != 48) {
            throw Exception("Size of timex_timex is not 48 but ${size} bytes")
        }
        let align = alignOf<timex_timex>()
        if (align != 4) {
            throw Exception("Alignment of timex_timex is not 4 but ${align} bytes")
        }
}

@C
public struct timex_named_timex_named {
    public var tai: Int32 = unsafe { zeroValue<Int32>() }
    var _bitfield_1: VArray<UInt8, $44> = VArray<UInt8, $44>(repeat: 0)
    public func a(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 0, 32) })
    }
    public mut func a(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 32, UInt64(val)) }
    }
    public func b(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 32, 32) })
    }
    public mut func b(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 32, 32, UInt64(val)) }
    }
    public func c(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 64, 32) })
    }
    public mut func c(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 64, 32, UInt64(val)) }
    }
    public func d(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 96, 32) })
    }
    public mut func d(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 96, 32, UInt64(val)) }
    }
    public func e(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 128, 32) })
    }
    public mut func e(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 128, 32, UInt64(val)) }
    }
    public func f(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 160, 32) })
    }
    public mut func f(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 160, 32, UInt64(val)) }
    }
    public func g(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 192, 32) })
    }
    public mut func g(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 192, 32, UInt64(val)) }
    }
    public func h(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 224, 32) })
    }
    public mut func h(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 224, 32, UInt64(val)) }
    }
    public func i(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 256, 32) })
    }
    public mut func i(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 256, 32, UInt64(val)) }
    }
    public func j(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 288, 32) })
    }
    public mut func j(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 288, 32, UInt64(val)) }
    }
    public func k(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 320, 32) })
    }
    public mut func k(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 320, 32, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<timex_named_timex_named>()
        if (size != 48) {
            throw Exception("Size of timex_named_timex_named is not 48 but ${size} bytes")
        }
        let align = alignOf<timex_named_timex_named>()
        if (align != 4) {
            throw Exception("Alignment of timex_named_timex_named is not 4 but ${align} bytes")
        }
}
