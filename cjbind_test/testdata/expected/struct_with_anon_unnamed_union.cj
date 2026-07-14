package cjbind_ffi

func __cjbind_read_UInt32_from_UInt32(storage: UInt32): UInt32 {
    var s = storage
    return unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt32_from_UInt32(storage: UInt32, val: UInt32): UInt32 {
    var s = storage
    unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_UInt16_from_UInt32(storage: UInt32): UInt16 {
    var s = storage
    return unsafe { CPointer<UInt16>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt16_from_UInt32(storage: UInt32, val: UInt16): UInt32 {
    var s = storage
    unsafe { CPointer<UInt16>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct foo__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func a(): UInt32 {
        return __cjbind_read_UInt32_from_UInt32(this._storage)
    }
    public mut func a(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, val)
    }
    public func b(): UInt16 {
        return __cjbind_read_UInt16_from_UInt32(this._storage)
    }
    public mut func b(val!: UInt16): Unit {
        this._storage = __cjbind_write_UInt16_from_UInt32(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of foo__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of foo__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct foo {
    public let __cjbind_anon_1: foo__cjbind_ty_1
    public init(__cjbind_anon_1: foo__cjbind_ty_1) {
        this.__cjbind_anon_1 = __cjbind_anon_1
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
