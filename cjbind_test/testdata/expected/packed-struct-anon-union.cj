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
public struct rte_memseg__cjbind_ty_1 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    public init() {}
    public mut prop addr: CPointer<Unit> {
        get() {
            return __cjbind_read_CPointer_Unit__from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_CPointer_Unit__from_UInt64(this._storage, value)
        }
    }
    public mut prop addr_64: UInt64 {
        get() {
            return __cjbind_read_UInt64_from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt64_from_UInt64(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_memseg__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of rte_memseg__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_memseg__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of rte_memseg__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

@C
public struct rte_memseg {
    let _cjbind_opaque_blob: VArray<UInt8, $44>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $44>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_memseg>()
        if (size != 44) {
            throw Exception("Size of rte_memseg is not 44 but ${size} bytes")
        }
        let align = alignOf<rte_memseg>()
        if (align != 1) {
            throw Exception("Alignment of rte_memseg is not 1 but ${align} bytes")
        }
}
