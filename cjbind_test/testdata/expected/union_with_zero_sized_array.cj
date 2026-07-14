package cjbind_ffi

func __cjbind_read_CPointer_UInt8__from_VArray_UInt8__2_(storage: VArray<UInt8, $2>): CPointer<UInt8> {
    var s = storage
    return unsafe { CPointer<CPointer<UInt8>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_CPointer_UInt8__from_VArray_UInt8__2_(storage: VArray<UInt8, $2>, val: CPointer<UInt8>): VArray<UInt8, $2> {
    var s = storage
    unsafe { CPointer<CPointer<UInt8>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_VArray_UInt8__1__from_VArray_UInt8__2_(storage: VArray<UInt8, $2>): VArray<UInt8, $1> {
    var s = storage
    return unsafe { CPointer<VArray<UInt8, $1>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_VArray_UInt8__1__from_VArray_UInt8__2_(storage: VArray<UInt8, $2>, val: VArray<UInt8, $1>): VArray<UInt8, $2> {
    var s = storage
    unsafe { CPointer<VArray<UInt8, $1>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_VArray_UInt8__2__from_VArray_UInt8__2_(storage: VArray<UInt8, $2>): VArray<UInt8, $2> {
    var s = storage
    return unsafe { CPointer<VArray<UInt8, $2>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_VArray_UInt8__2__from_VArray_UInt8__2_(storage: VArray<UInt8, $2>, val: VArray<UInt8, $2>): VArray<UInt8, $2> {
    var s = storage
    unsafe { CPointer<VArray<UInt8, $2>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct U {
    var _storage: VArray<UInt8, $2> = unsafe { zeroValue<VArray<UInt8, $2>>() }
    public init() {}
    public func d0(): CPointer<UInt8> {
        return __cjbind_read_CPointer_UInt8__from_VArray_UInt8__2_(this._storage)
    }
    public mut func d0(val!: CPointer<UInt8>): Unit {
        this._storage = __cjbind_write_CPointer_UInt8__from_VArray_UInt8__2_(this._storage, val)
    }
    public func d1(): VArray<UInt8, $1> {
        return __cjbind_read_VArray_UInt8__1__from_VArray_UInt8__2_(this._storage)
    }
    public mut func d1(val!: VArray<UInt8, $1>): Unit {
        this._storage = __cjbind_write_VArray_UInt8__1__from_VArray_UInt8__2_(this._storage, val)
    }
    public func d2(): VArray<UInt8, $2> {
        return __cjbind_read_VArray_UInt8__2__from_VArray_UInt8__2_(this._storage)
    }
    public mut func d2(val!: VArray<UInt8, $2>): Unit {
        this._storage = __cjbind_write_VArray_UInt8__2__from_VArray_UInt8__2_(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<U>()
        if (size != 2) {
            throw Exception("Size of U is not 2 but ${size} bytes")
        }
        let align = alignOf<U>()
        if (align != 1) {
            throw Exception("Alignment of U is not 1 but ${align} bytes")
        }
}
