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
public struct Struct_Struct {
    var _bitfield_1: VArray<UInt8, $4> = VArray<UInt8, $4>(repeat: 0)
    public func a(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read(inout s, 0, 1) })
    }
    public mut func a(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 1, UInt64(val)) }
    }
    public func b(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read(inout s, 1, 1) })
    }
    public mut func b(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 1, 1, UInt64(val)) }
    }
    public func c(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read(inout s, 2, 6) })
    }
    public mut func c(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 2, 6, UInt64(val)) }
    }
    public func d(): UInt16 {
        var s = this._bitfield_1
        return UInt16(unsafe { __cjbind_bitfield_read(inout s, 8, 16) })
    }
    public mut func d(val!: UInt16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 8, 16, UInt64(val)) }
    }
    public func e(): UInt8 {
        var s = this._bitfield_1
        return UInt8(unsafe { __cjbind_bitfield_read(inout s, 24, 8) })
    }
    public mut func e(val!: UInt8): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 24, 8, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Struct_Struct>()
        if (size != 4) {
            throw Exception("Size of Struct_Struct is not 4 but ${size} bytes")
        }
        let align = alignOf<Struct_Struct>()
        if (align != 1) {
            throw Exception("Alignment of Struct_Struct is not 1 but ${align} bytes")
        }
}

@C
public struct Inner_Inner {
    var _bitfield_1: VArray<UInt8, $4> = VArray<UInt8, $4>(repeat: 0)
    public func a(): UInt16 {
        var s = this._bitfield_1
        return UInt16(unsafe { __cjbind_bitfield_read(inout s, 0, 16) })
    }
    public mut func a(val!: UInt16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 16, UInt64(val)) }
    }
    public func b(): UInt16 {
        var s = this._bitfield_1
        return UInt16(unsafe { __cjbind_bitfield_read(inout s, 16, 16) })
    }
    public mut func b(val!: UInt16): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 16, 16, UInt64(val)) }
    }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Inner_Inner>()
        if (size != 4) {
            throw Exception("Size of Inner_Inner is not 4 but ${size} bytes")
        }
        let align = alignOf<Inner_Inner>()
        if (align != 2) {
            throw Exception("Alignment of Inner_Inner is not 2 but ${align} bytes")
        }
}

@C
public struct Outer_Outer {
    let _cjbind_opaque_blob: VArray<UInt8, $4>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Outer>()
        if (size != 4) {
            throw Exception("Size of Outer_Outer is not 4 but ${size} bytes")
        }
        let align = alignOf<Outer_Outer>()
        if (align != 1) {
            throw Exception("Alignment of Outer_Outer is not 1 but ${align} bytes")
        }
}
