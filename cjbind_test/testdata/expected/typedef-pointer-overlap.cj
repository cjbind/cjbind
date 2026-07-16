package cjbind_ffi

func __cjbind_read_Int32_from_UInt32(storage: UInt32): Int32 {
    var s = storage
    return unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Int32_from_UInt32(storage: UInt32, val: Int32): UInt32 {
    var s = storage
    unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct foo {
    public var inner: UInt8
    public init(inner: UInt8) {
        this.inner = inner
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<foo>()
        if (size != 1) {
            throw Exception("Size of foo is not 1 but ${size} bytes")
        }
        let align = alignOf<foo>()
        if (align != 1) {
            throw Exception("Alignment of foo is not 1 but ${align} bytes")
        }
}

public type foo_ptr = CPointer<foo>

@C
public struct bar {
    public var inner: UInt8
    public init(inner: UInt8) {
        this.inner = inner
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bar>()
        if (size != 1) {
            throw Exception("Size of bar is not 1 but ${size} bytes")
        }
        let align = alignOf<bar>()
        if (align != 1) {
            throw Exception("Alignment of bar is not 1 but ${align} bytes")
        }
}

public type bar_ptr = CPointer<bar>

@C
public struct baz {
    init() {
        throw Exception("type should not be inited")
    }
}

public type baz_ptr = CPointer<baz>

@C
public struct cat {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop standard_issue: Int32 {
        get() {
            return __cjbind_read_Int32_from_UInt32(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_Int32_from_UInt32(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<cat>()
        if (size != 4) {
            throw Exception("Size of cat is not 4 but ${size} bytes")
        }
        let align = alignOf<cat>()
        if (align != 4) {
            throw Exception("Alignment of cat is not 4 but ${align} bytes")
        }
}

public type cat_ptr = CPointer<cat>

public const mad_scientist: mad = 0

public type mad = UInt32

public type mad_ptr = CPointer<mad>

foreign func takes_foo_ptr(arg1: foo_ptr): Unit

foreign func takes_foo_struct(arg1: foo): Unit

foreign func takes_bar_ptr(arg1: bar_ptr): Unit

foreign func takes_bar_struct(arg1: bar): Unit

foreign func takes_baz_ptr(arg1: baz_ptr): Unit

foreign func takes_baz_struct(arg1: baz): Unit

foreign func takes_cat_ptr(arg1: cat_ptr): Unit

foreign func takes_mad_ptr(arg1: mad_ptr): Unit

foreign func takes_mad_enum(arg1: mad): Unit
