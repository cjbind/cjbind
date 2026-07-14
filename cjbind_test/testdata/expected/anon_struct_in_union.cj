package cjbind_ffi

func __cjbind_read_s__cjbind_ty_1_inner_from_UInt32(storage: UInt32): s__cjbind_ty_1_inner {
    var s = storage
    return unsafe { CPointer<s__cjbind_ty_1_inner>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_s__cjbind_ty_1_inner_from_UInt32(storage: UInt32, val: s__cjbind_ty_1_inner): UInt32 {
    var s = storage
    unsafe { CPointer<s__cjbind_ty_1_inner>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct s__cjbind_ty_1_inner {
    public let b: Int32
    public init(b: Int32) {
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<s__cjbind_ty_1_inner>()
        if (size != 4) {
            throw Exception("Size of s__cjbind_ty_1_inner is not 4 but ${size} bytes")
        }
        let align = alignOf<s__cjbind_ty_1_inner>()
        if (align != 4) {
            throw Exception("Alignment of s__cjbind_ty_1_inner is not 4 but ${align} bytes")
        }
}

@C
public struct s__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func field(): s__cjbind_ty_1_inner {
        return __cjbind_read_s__cjbind_ty_1_inner_from_UInt32(this._storage)
    }
    public mut func field(val!: s__cjbind_ty_1_inner): Unit {
        this._storage = __cjbind_write_s__cjbind_ty_1_inner_from_UInt32(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<s__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of s__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<s__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of s__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct s {
    public let u: s__cjbind_ty_1
    public init(u: s__cjbind_ty_1) {
        this.u = u
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<s>()
        if (size != 4) {
            throw Exception("Size of s is not 4 but ${size} bytes")
        }
        let align = alignOf<s>()
        if (align != 4) {
            throw Exception("Alignment of s is not 4 but ${align} bytes")
        }
}
