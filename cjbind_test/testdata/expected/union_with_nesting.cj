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

func __cjbind_read_UInt32_from_UInt32(storage: UInt32): UInt32 {
    var s = storage
    return unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt32_from_UInt32(storage: UInt32, val: UInt32): UInt32 {
    var s = storage
    unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct foo__cjbind_ty_1__cjbind_ty_1 {
    var _storage: UInt16 = unsafe { zeroValue<UInt16>() }
    public init() {}
    public mut prop b1: UInt16 {
        get() {
            return __cjbind_read_UInt16_from_UInt16(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt16_from_UInt16(this._storage, value)
        }
    }
    public mut prop b2: UInt16 {
        get() {
            return __cjbind_read_UInt16_from_UInt16(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt16_from_UInt16(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1__cjbind_ty_1>()
        if (size != 2) {
            throw Exception("Size of foo__cjbind_ty_1__cjbind_ty_1 is not 2 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1__cjbind_ty_1>()
        if (align != 2) {
            throw Exception("Alignment of foo__cjbind_ty_1__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct foo__cjbind_ty_1__cjbind_ty_2 {
    var _storage: UInt16 = unsafe { zeroValue<UInt16>() }
    public init() {}
    public mut prop c1: UInt16 {
        get() {
            return __cjbind_read_UInt16_from_UInt16(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt16_from_UInt16(this._storage, value)
        }
    }
    public mut prop c2: UInt16 {
        get() {
            return __cjbind_read_UInt16_from_UInt16(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt16_from_UInt16(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1__cjbind_ty_2>()
        if (size != 2) {
            throw Exception("Size of foo__cjbind_ty_1__cjbind_ty_2 is not 2 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1__cjbind_ty_2>()
        if (align != 2) {
            throw Exception("Alignment of foo__cjbind_ty_1__cjbind_ty_2 is not 2 but ${align} bytes")
        }
}

@C
public struct foo__cjbind_ty_1 {
    public let __cjbind_anon_1: foo__cjbind_ty_1__cjbind_ty_1
    public let __cjbind_anon_2: foo__cjbind_ty_1__cjbind_ty_2
    public init(__cjbind_anon_1: foo__cjbind_ty_1__cjbind_ty_1, __cjbind_anon_2: foo__cjbind_ty_1__cjbind_ty_2) {
        this.__cjbind_anon_1 = __cjbind_anon_1
        this.__cjbind_anon_2 = __cjbind_anon_2
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
        if (align != 2) {
            throw Exception("Alignment of foo__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct foo {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop a: UInt32 {
        get() {
            return __cjbind_read_UInt32_from_UInt32(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, value)
        }
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
