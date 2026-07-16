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
public struct pixel__cjbind_ty_1 {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public var a: UInt8
    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        this.r = r
        this.g = g
        this.b = b
        this.a = a
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<pixel__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of pixel__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<pixel__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of pixel__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct pixel {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop rgba: UInt32 {
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
        let size = sizeOf<pixel>()
        if (size != 4) {
            throw Exception("Size of pixel is not 4 but ${size} bytes")
        }
        let align = alignOf<pixel>()
        if (align != 4) {
            throw Exception("Alignment of pixel is not 4 but ${align} bytes")
        }
}
