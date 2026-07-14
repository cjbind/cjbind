package cjbind_ffi

func __cjbind_read_UInt16_from_UInt16(storage: UInt16): UInt16 {
    var s = storage
    return unsafe { CPointer<UInt16>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt16_from_UInt16(storage: UInt16, val: UInt16): UInt16 {
    var s = storage
    unsafe { CPointer<UInt16>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_UInt8_from_UInt16(storage: UInt16): UInt8 {
    var s = storage
    return unsafe { CPointer<UInt8>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt8_from_UInt16(storage: UInt16, val: UInt8): UInt16 {
    var s = storage
    unsafe { CPointer<UInt8>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_UInt32_from_UInt32(storage: UInt32): UInt32 {
    var s = storage
    return unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt32_from_UInt32(storage: UInt32, val: UInt32): UInt32 {
    var s = storage
    unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_foo__cjbind_ty_1_from_UInt32(storage: UInt32): foo__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<foo__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_foo__cjbind_ty_1_from_UInt32(storage: UInt32, val: foo__cjbind_ty_1): UInt32 {
    var s = storage
    unsafe { CPointer<foo__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct foo__cjbind_ty_1 {
    var _storage: UInt16 = unsafe { zeroValue<UInt16>() }
    public init() {}
    public func b(): UInt16 {
        return __cjbind_read_UInt16_from_UInt16(this._storage)
    }
    public mut func b(val!: UInt16): Unit {
        this._storage = __cjbind_write_UInt16_from_UInt16(this._storage, val)
    }
    public func c(): UInt8 {
        return __cjbind_read_UInt8_from_UInt16(this._storage)
    }
    public mut func c(val!: UInt8): Unit {
        this._storage = __cjbind_write_UInt8_from_UInt16(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1>()
        if (size != 2) {
            throw Exception("Size of foo__cjbind_ty_1 is not 2 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1>()
        if (align != 2) {
            throw Exception("Alignment of foo__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct foo {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func a(): UInt32 {
        return __cjbind_read_UInt32_from_UInt32(this._storage)
    }
    public mut func a(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, val)
    }
    public func __cjbind_anon_1(): foo__cjbind_ty_1 {
        return __cjbind_read_foo__cjbind_ty_1_from_UInt32(this._storage)
    }
    public mut func __cjbind_anon_1(val!: foo__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_foo__cjbind_ty_1_from_UInt32(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 4) {
            throw Exception("Size of foo is not 4 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 4) {
            throw Exception("Alignment of foo is not 4 but ${align} bytes")
        }
}
