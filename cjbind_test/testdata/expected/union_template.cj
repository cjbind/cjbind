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

func __cjbind_read_Int16_from_UInt64(storage: UInt64): Int16 {
    var s = storage
    return unsafe { CPointer<Int16>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Int16_from_UInt64(storage: UInt64, val: Int16): UInt64 {
    var s = storage
    unsafe { CPointer<Int16>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_CPointer_Int32__from_UInt64(storage: UInt64): CPointer<Int32> {
    var s = storage
    return unsafe { CPointer<CPointer<Int32>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_CPointer_Int32__from_UInt64(storage: UInt64, val: CPointer<Int32>): UInt64 {
    var s = storage
    unsafe { CPointer<CPointer<Int32>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_Int32_from_UInt64(storage: UInt64): Int32 {
    var s = storage
    return unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Int32_from_UInt64(storage: UInt64, val: Int32): UInt64 {
    var s = storage
    unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct NastyStruct__cjbind_ty_1 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    private init() {}
    public mut prop mFoo: CPointer<Unit> {
        get() {
            return __cjbind_read_CPointer_Unit__from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_CPointer_Unit__from_UInt64(this._storage, value)
        }
    }
    public mut prop mDummy: UInt64 {
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
        let size = sizeOf<NastyStruct__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of NastyStruct__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<NastyStruct__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of NastyStruct__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

@C
public struct NastyStruct__cjbind_ty_2 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    private init() {}
    public mut prop wat: Int16 {
        get() {
            return __cjbind_read_Int16_from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_Int16_from_UInt64(this._storage, value)
        }
    }
    public mut prop wut: CPointer<Int32> {
        get() {
            return __cjbind_read_CPointer_Int32__from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_CPointer_Int32__from_UInt64(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NastyStruct__cjbind_ty_2>()
        if (size != 8) {
            throw Exception("Size of NastyStruct__cjbind_ty_2 is not 8 but ${size} bytes")
        }
        let align = alignOf<NastyStruct__cjbind_ty_2>()
        if (align != 8) {
            throw Exception("Alignment of NastyStruct__cjbind_ty_2 is not 8 but ${align} bytes")
        }
}

@C
public struct NastyStruct {
    public var mIsSome: Bool
    public let mStorage: NastyStruct__cjbind_ty_1
    public let __cjbind_anon_1: NastyStruct__cjbind_ty_2
    private init(mIsSome: Bool, mStorage: NastyStruct__cjbind_ty_1, __cjbind_anon_1: NastyStruct__cjbind_ty_2) {
        this.mIsSome = mIsSome
        this.mStorage = mStorage
        this.__cjbind_anon_1 = __cjbind_anon_1
    }
}

@C
public struct Whatever {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    private init() {}
    public mut prop mTPtr: CPointer<Unit> {
        get() {
            return __cjbind_read_CPointer_Unit__from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_CPointer_Unit__from_UInt64(this._storage, value)
        }
    }
    public mut prop mInt: Int32 {
        get() {
            return __cjbind_read_Int32_from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_Int32_from_UInt64(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Whatever>()
        if (size != 8) {
            throw Exception("Size of Whatever is not 8 but ${size} bytes")
        }
        let align = alignOf<Whatever>()
        if (align != 8) {
            throw Exception("Alignment of Whatever is not 8 but ${align} bytes")
        }
}
