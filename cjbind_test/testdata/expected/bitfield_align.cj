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
public struct A {
    public var x: UInt8 = unsafe { zeroValue<UInt8>() }
    var _bitfield_1: VArray<UInt8, $2> = unsafe { zeroValue<VArray<UInt8, $2>>() }
    public mut prop b1: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 1, UInt64(value)) }
        }
    }
    public mut prop b2: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 1, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 1, 1, UInt64(value)) }
        }
    }
    public mut prop b3: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 2, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 2, 1, UInt64(value)) }
        }
    }
    public mut prop b4: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 3, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 3, 1, UInt64(value)) }
        }
    }
    public mut prop b5: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 4, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 4, 1, UInt64(value)) }
        }
    }
    public mut prop b6: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 5, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 5, 1, UInt64(value)) }
        }
    }
    public mut prop b7: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 6, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 6, 1, UInt64(value)) }
        }
    }
    public mut prop b8: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 7, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 7, 1, UInt64(value)) }
        }
    }
    public mut prop b9: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 8, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 8, 1, UInt64(value)) }
        }
    }
    public mut prop b10: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 9, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 9, 1, UInt64(value)) }
        }
    }
    public var y: UInt8 = unsafe { zeroValue<UInt8>() }
    let _cjbind_bitfield_alignment_marker: VArray<UInt32, $0> = unsafe { zeroValue<VArray<UInt32, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<A>()
        if (size != 4) {
            throw Exception("Size of A is not 4 but ${size} bytes")
        }
        let align = alignOf<A>()
        if (align != 4) {
            throw Exception("Alignment of A is not 4 but ${align} bytes")
        }
}

@C
public struct B {
    var _bitfield_1: UInt32 = unsafe { zeroValue<UInt32>() }
    public mut prop foo: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 31) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 31, UInt64(value)) }
        }
    }
    public mut prop bar: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 31, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 31, 1, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt32, $0> = unsafe { zeroValue<VArray<UInt32, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<B>()
        if (size != 4) {
            throw Exception("Size of B is not 4 but ${size} bytes")
        }
        let align = alignOf<B>()
        if (align != 4) {
            throw Exception("Alignment of B is not 4 but ${align} bytes")
        }
}

@C
public struct C {
    public var x: UInt8 = unsafe { zeroValue<UInt8>() }
    var _bitfield_1: VArray<UInt8, $3> = unsafe { zeroValue<VArray<UInt8, $3>>() }
    public mut prop b1: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 1, UInt64(value)) }
        }
    }
    public mut prop b2: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 1, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 1, 1, UInt64(value)) }
        }
    }
    public var baz: UInt32 = unsafe { zeroValue<UInt32>() }
    let _cjbind_bitfield_alignment_marker: VArray<UInt32, $0> = unsafe { zeroValue<VArray<UInt32, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<C>()
        if (size != 8) {
            throw Exception("Size of C is not 8 but ${size} bytes")
        }
        let align = alignOf<C>()
        if (align != 4) {
            throw Exception("Alignment of C is not 4 but ${align} bytes")
        }
}

@C
public struct Date1 {
    var _bitfield_1: VArray<UInt16, $2> = unsafe { zeroValue<VArray<UInt16, $2>>() }
    public mut prop nWeekDay: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 3) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 3, UInt64(value)) }
        }
    }
    public mut prop nMonthDay: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 3, 6) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 3, 6, UInt64(value)) }
        }
    }
    public mut prop nMonth: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 9, 5) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 9, 5, UInt64(value)) }
        }
    }
    public mut prop nYear: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 16, 8) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 16, 8, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt16, $0> = unsafe { zeroValue<VArray<UInt16, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Date1>()
        if (size != 4) {
            throw Exception("Size of Date1 is not 4 but ${size} bytes")
        }
        let align = alignOf<Date1>()
        if (align != 2) {
            throw Exception("Alignment of Date1 is not 2 but ${align} bytes")
        }
}

@C
public struct Date2 {
    var _bitfield_1: VArray<UInt16, $2> = unsafe { zeroValue<VArray<UInt16, $2>>() }
    public mut prop nWeekDay: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 3) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 3, UInt64(value)) }
        }
    }
    public mut prop nMonthDay: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 3, 6) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 3, 6, UInt64(value)) }
        }
    }
    public mut prop nMonth: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 9, 5) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 9, 5, UInt64(value)) }
        }
    }
    public mut prop nYear: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 16, 8) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 16, 8, UInt64(value)) }
        }
    }
    public mut prop byte: UInt8 {
        get() {
            var s = this._bitfield_1
            return UInt8(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 24, 8) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 24, 8, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt16, $0> = unsafe { zeroValue<VArray<UInt16, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Date2>()
        if (size != 4) {
            throw Exception("Size of Date2 is not 4 but ${size} bytes")
        }
        let align = alignOf<Date2>()
        if (align != 2) {
            throw Exception("Alignment of Date2 is not 2 but ${align} bytes")
        }
}

@C
public struct Date3 {
    var _bitfield_1: VArray<UInt8, $3> = unsafe { zeroValue<VArray<UInt8, $3>>() }
    public mut prop nWeekDay: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 3) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 3, UInt64(value)) }
        }
    }
    public mut prop nMonthDay: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 3, 6) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 3, 6, UInt64(value)) }
        }
    }
    public mut prop nMonth: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 9, 5) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 9, 5, UInt64(value)) }
        }
    }
    public mut prop nYear: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 16, 8) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 16, 8, UInt64(value)) }
        }
    }
    public var byte: UInt8 = unsafe { zeroValue<UInt8>() }
    let _cjbind_bitfield_alignment_marker: VArray<UInt16, $0> = unsafe { zeroValue<VArray<UInt16, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Date3>()
        if (size != 4) {
            throw Exception("Size of Date3 is not 4 but ${size} bytes")
        }
        let align = alignOf<Date3>()
        if (align != 2) {
            throw Exception("Alignment of Date3 is not 2 but ${align} bytes")
        }
}
