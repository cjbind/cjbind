package cjbind_ffi

func __cjbind_read_UInt8_from_VArray_UInt8__16_(storage: VArray<UInt8, $16>): UInt8 {
    var s = storage
    return unsafe { CPointer<UInt8>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt8_from_VArray_UInt8__16_(storage: VArray<UInt8, $16>, val: UInt8): VArray<UInt8, $16> {
    var s = storage
    unsafe { CPointer<UInt8>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_Bar_Bar_from_VArray_UInt8__16_(storage: VArray<UInt8, $16>): Bar_Bar {
    var s = storage
    return unsafe { CPointer<Bar_Bar>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Bar_Bar_from_VArray_UInt8__16_(storage: VArray<UInt8, $16>, val: Bar_Bar): VArray<UInt8, $16> {
    var s = storage
    unsafe { CPointer<Bar_Bar>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct Bar_Bar {
    var _storage: VArray<UInt8, $16> = unsafe { zeroValue<VArray<UInt8, $16>>() }
    public init() {}
    public func foo(): UInt8 {
        return __cjbind_read_UInt8_from_VArray_UInt8__16_(this._storage)
    }
    public mut func foo(val!: UInt8): Unit {
        this._storage = __cjbind_write_UInt8_from_VArray_UInt8__16_(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Bar_Bar>()
        if (size != 16) {
            throw Exception("Size of Bar_Bar is not 16 but ${size} bytes")
        }
        let align = alignOf<Bar_Bar>()
        if (align != 16) {
            throw Exception("Alignment of Bar_Bar is not 16 but ${align} bytes")
        }
}

@C
public struct Baz_Baz {
    var _storage: VArray<UInt8, $16> = unsafe { zeroValue<VArray<UInt8, $16>>() }
    public init() {}
    public func bar(): Bar_Bar {
        return __cjbind_read_Bar_Bar_from_VArray_UInt8__16_(this._storage)
    }
    public mut func bar(val!: Bar_Bar): Unit {
        this._storage = __cjbind_write_Bar_Bar_from_VArray_UInt8__16_(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Baz_Baz>()
        if (size != 16) {
            throw Exception("Size of Baz_Baz is not 16 but ${size} bytes")
        }
        let align = alignOf<Baz_Baz>()
        if (align != 16) {
            throw Exception("Alignment of Baz_Baz is not 16 but ${align} bytes")
        }
}
