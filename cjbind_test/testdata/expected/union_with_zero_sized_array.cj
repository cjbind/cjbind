package cjbind_ffi

func __cjbind_read_CPointer_UInt8_(ptr: CPointer<UInt8>): CPointer<UInt8> {
    return unsafe { CPointer<CPointer<UInt8>>(ptr).read() }
}

func __cjbind_write_CPointer_UInt8_(ptr: CPointer<UInt8>, val: CPointer<UInt8>): Unit {
    unsafe { CPointer<CPointer<UInt8>>(ptr).write(val) }
}

func __cjbind_read_VArray_UInt8__1_(ptr: CPointer<UInt8>): VArray<UInt8, $1> {
    return unsafe { CPointer<VArray<UInt8, $1>>(ptr).read() }
}

func __cjbind_write_VArray_UInt8__1_(ptr: CPointer<UInt8>, val: VArray<UInt8, $1>): Unit {
    unsafe { CPointer<VArray<UInt8, $1>>(ptr).write(val) }
}

func __cjbind_read_VArray_UInt8__2_(ptr: CPointer<UInt8>): VArray<UInt8, $2> {
    return unsafe { CPointer<VArray<UInt8, $2>>(ptr).read() }
}

func __cjbind_write_VArray_UInt8__2_(ptr: CPointer<UInt8>, val: VArray<UInt8, $2>): Unit {
    unsafe { CPointer<VArray<UInt8, $2>>(ptr).write(val) }
}

@C
public struct U_U {
    var _storage: VArray<UInt8, $2> = unsafe { zeroValue<VArray<UInt8, $2>>() }
    public init() {}
    public func d0(): CPointer<UInt8> {
        var s = this._storage
        return unsafe { __cjbind_read_CPointer_UInt8_(CPointer<UInt8>(inout s)) }
    }
    public mut func d0(val!: CPointer<UInt8>): Unit {
        unsafe { __cjbind_write_CPointer_UInt8_(CPointer<UInt8>(inout this._storage), val) }
    }
    public func d1(): VArray<UInt8, $1> {
        var s = this._storage
        return unsafe { __cjbind_read_VArray_UInt8__1_(CPointer<UInt8>(inout s)) }
    }
    public mut func d1(val!: VArray<UInt8, $1>): Unit {
        unsafe { __cjbind_write_VArray_UInt8__1_(CPointer<UInt8>(inout this._storage), val) }
    }
    public func d2(): VArray<UInt8, $2> {
        var s = this._storage
        return unsafe { __cjbind_read_VArray_UInt8__2_(CPointer<UInt8>(inout s)) }
    }
    public mut func d2(val!: VArray<UInt8, $2>): Unit {
        unsafe { __cjbind_write_VArray_UInt8__2_(CPointer<UInt8>(inout this._storage), val) }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<U_U>()
        if (size != 2) {
            throw Exception("Size of U_U is not 2 but ${size} bytes")
        }
        let align = alignOf<U_U>()
        if (align != 1) {
            throw Exception("Alignment of U_U is not 1 but ${align} bytes")
        }
}
