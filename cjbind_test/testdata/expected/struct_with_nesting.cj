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

@C
public struct foo__cjbind_ty_1__cjbind_ty_1 {
    public var c1: UInt16
    public var c2: UInt16
    public init(c1: UInt16, c2: UInt16) {
        this.c1 = c1
        this.c2 = c2
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
        if (align != 2) {
            throw Exception("Alignment of foo__cjbind_ty_1__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct foo__cjbind_ty_1__cjbind_ty_2 {
    public var d1: UInt8
    public var d2: UInt8
    public var d3: UInt8
    public var d4: UInt8
    public init(d1: UInt8, d2: UInt8, d3: UInt8, d4: UInt8) {
        this.d1 = d1
        this.d2 = d2
        this.d3 = d3
        this.d4 = d4
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo__cjbind_ty_1__cjbind_ty_2>()
        if (size != 4) {
            throw Exception("Size of foo__cjbind_ty_1__cjbind_ty_2 is not 4 but ${size} bytes")
        }
        let align = alignOf<foo__cjbind_ty_1__cjbind_ty_2>()
        if (align != 1) {
            throw Exception("Alignment of foo__cjbind_ty_1__cjbind_ty_2 is not 1 but ${align} bytes")
        }
}

@C
public struct foo__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop b: UInt32 {
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
    public var a: UInt32
    public let __cjbind_anon_1: foo__cjbind_ty_1
    public init(a: UInt32, __cjbind_anon_1: foo__cjbind_ty_1) {
        this.a = a
        this.__cjbind_anon_1 = __cjbind_anon_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 8) {
            throw Exception("Size of foo is not 8 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 4) {
            throw Exception("Alignment of foo is not 4 but ${align} bytes")
        }
}
