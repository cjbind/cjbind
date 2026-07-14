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

func __cjbind_read_Int32_from_UInt32(storage: UInt32): Int32 {
    var s = storage
    return unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Int32_from_UInt32(storage: UInt32, val: Int32): UInt32 {
    var s = storage
    unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_foo__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32): foo__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<foo__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_foo__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32, val: foo__cjbind_ty_1__cjbind_ty_1): UInt32 {
    var s = storage
    unsafe { CPointer<foo__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct foo__cjbind_ty_1__cjbind_ty_1 {
    var _bitfield_1: VArray<UInt8, $4> = VArray<UInt8, $4>(repeat: 0)
    public func b(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 0, 7) })
    }
    public mut func b(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 7, UInt64(val)) }
    }
    public func c(): Int32 {
        var s = this._bitfield_1
        return Int32(unsafe { __cjbind_bitfield_read_signed(inout s, 7, 25) })
    }
    public mut func c(val!: Int32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 7, 25, UInt64(val)) }
    }
    public init() {}
    public func clone(): foo__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "foo__cjbind_ty_1__cjbind_ty_1 {"
        output += " b: "
        output += this.b().toString()
        output += ", c: "
        output += this.c().toString()
        output += " }"
        return output
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of foo__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of foo__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct foo_foo {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func a(): Int32 {
        return __cjbind_read_Int32_from_UInt32(this._storage)
    }
    public mut func a(val!: Int32): Unit {
        this._storage = __cjbind_write_Int32_from_UInt32(this._storage, val)
    }
    public func __cjbind_anon_1(): foo__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_foo__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage)
    }
    public mut func __cjbind_anon_1(val!: foo__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_foo__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage, val)
    }
    public func clone(): foo_foo {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo_foo>()
        if (size != 4) {
            throw Exception("Size of foo_foo is not 4 but ${size} bytes")
        }
        let align = alignOf<foo_foo>()
        if (align != 4) {
            throw Exception("Alignment of foo_foo is not 4 but ${align} bytes")
        }
}
