package cjbind_ffi

func __cjbind_read_CPointer_Unit__from_UInt64(storage: UInt64): CPointer<Unit> {
    var s = storage
    return unsafe { CPointer<CPointer<Unit>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_CPointer_Unit__from_UInt64(storage: UInt64, val: CPointer<Unit>): UInt64 {
    var s = storage
    unsafe { CPointer<CPointer<Unit>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_UInt64_from_UInt64(storage: UInt64): UInt64 {
    var s = storage
    return unsafe { CPointer<UInt64>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt64_from_UInt64(storage: UInt64, val: UInt64): UInt64 {
    var s = storage
    unsafe { CPointer<UInt64>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct rte_memseg__cjbind_ty_1__cjbind_ty_1 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    public init() {}
    public func addr(): CPointer<Unit> {
        return __cjbind_read_CPointer_Unit__from_UInt64(this._storage)
    }
    public mut func addr(val!: CPointer<Unit>): Unit {
        this._storage = __cjbind_write_CPointer_Unit__from_UInt64(this._storage, val)
    }
    public func addr_64(): UInt64 {
        return __cjbind_read_UInt64_from_UInt64(this._storage)
    }
    public mut func addr_64(val!: UInt64): Unit {
        this._storage = __cjbind_write_UInt64_from_UInt64(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_memseg__cjbind_ty_1__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of rte_memseg__cjbind_ty_1__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_memseg__cjbind_ty_1__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of rte_memseg__cjbind_ty_1__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}
