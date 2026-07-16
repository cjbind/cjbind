package cjbind_ffi

func __cjbind_read_UInt32_from_UInt32(ptr: CPointer<UInt8>): UInt32 {
    return unsafe { CPointer<UInt32>(ptr).read() }
}

func __cjbind_write_UInt32_from_UInt32(ptr: CPointer<UInt8>, val: UInt32): Unit {
    unsafe { CPointer<UInt32>(ptr).write(val) }
}

func __cjbind_read_UInt16_from_UInt32(ptr: CPointer<UInt8>): UInt16 {
    return unsafe { CPointer<UInt16>(ptr).read() }
}

func __cjbind_write_UInt16_from_UInt32(ptr: CPointer<UInt8>, val: UInt16): Unit {
    unsafe { CPointer<UInt16>(ptr).write(val) }
}

@C
public struct simple_union {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop u32: UInt32 {
        get() {
            var s = this._storage
            return unsafe { __cjbind_read_UInt32_from_UInt32(CPointer<UInt8>(inout s)) }
        }
        set(value) {
            unsafe { __cjbind_write_UInt32_from_UInt32(CPointer<UInt8>(inout this._storage), value) }
        }
    }
    public mut prop u16: UInt16 {
        get() {
            var s = this._storage
            return unsafe { __cjbind_read_UInt16_from_UInt32(CPointer<UInt8>(inout s)) }
        }
        set(value) {
            unsafe { __cjbind_write_UInt16_from_UInt32(CPointer<UInt8>(inout this._storage), value) }
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<simple_union>()
        if (size != 4) {
            throw Exception("Size of simple_union is not 4 but ${size} bytes")
        }
        let align = alignOf<simple_union>()
        if (align != 4) {
            throw Exception("Alignment of simple_union is not 4 but ${align} bytes")
        }
}

public type simple_union_t = simple_union
