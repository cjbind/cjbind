package cjbind_ffi

func __cjbind_read_color__cjbind_ty_1_from_VArray_UInt8__3_(storage: VArray<UInt8, $3>): color__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<color__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_color__cjbind_ty_1_from_VArray_UInt8__3_(storage: VArray<UInt8, $3>, val: color__cjbind_ty_1): VArray<UInt8, $3> {
    var s = storage
    unsafe { CPointer<color__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_color__cjbind_ty_2_from_VArray_UInt8__3_(storage: VArray<UInt8, $3>): color__cjbind_ty_2 {
    var s = storage
    return unsafe { CPointer<color__cjbind_ty_2>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_color__cjbind_ty_2_from_VArray_UInt8__3_(storage: VArray<UInt8, $3>, val: color__cjbind_ty_2): VArray<UInt8, $3> {
    var s = storage
    unsafe { CPointer<color__cjbind_ty_2>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_VArray_UInt8__3__from_VArray_UInt8__3_(storage: VArray<UInt8, $3>): VArray<UInt8, $3> {
    var s = storage
    return unsafe { CPointer<VArray<UInt8, $3>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_VArray_UInt8__3__from_VArray_UInt8__3_(storage: VArray<UInt8, $3>, val: VArray<UInt8, $3>): VArray<UInt8, $3> {
    var s = storage
    unsafe { CPointer<VArray<UInt8, $3>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct color__cjbind_ty_1 {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8
    public init(r: UInt8, g: UInt8, b: UInt8) {
        this.r = r
        this.g = g
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<color__cjbind_ty_1>()
        if (size != 3) {
            throw Exception("Size of color__cjbind_ty_1 is not 3 but ${size} bytes")
        }
        let align = alignOf<color__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of color__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct color__cjbind_ty_2 {
    public let y: UInt8
    public let u: UInt8
    public let v: UInt8
    public init(y: UInt8, u: UInt8, v: UInt8) {
        this.y = y
        this.u = u
        this.v = v
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<color__cjbind_ty_2>()
        if (size != 3) {
            throw Exception("Size of color__cjbind_ty_2 is not 3 but ${size} bytes")
        }
        let align = alignOf<color__cjbind_ty_2>()
        if (align != 1) {
            throw Exception("Alignment of color__cjbind_ty_2 is not 1 but ${align} bytes")
        }
}

@C
public struct color {
    var _storage: VArray<UInt8, $3> = unsafe { zeroValue<VArray<UInt8, $3>>() }
    public init() {}
    public func __cjbind_anon_1(): color__cjbind_ty_1 {
        return __cjbind_read_color__cjbind_ty_1_from_VArray_UInt8__3_(this._storage)
    }
    public mut func __cjbind_anon_1(val!: color__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_color__cjbind_ty_1_from_VArray_UInt8__3_(this._storage, val)
    }
    public func __cjbind_anon_2(): color__cjbind_ty_2 {
        return __cjbind_read_color__cjbind_ty_2_from_VArray_UInt8__3_(this._storage)
    }
    public mut func __cjbind_anon_2(val!: color__cjbind_ty_2): Unit {
        this._storage = __cjbind_write_color__cjbind_ty_2_from_VArray_UInt8__3_(this._storage, val)
    }
    public func v3(): VArray<UInt8, $3> {
        return __cjbind_read_VArray_UInt8__3__from_VArray_UInt8__3_(this._storage)
    }
    public mut func v3(val!: VArray<UInt8, $3>): Unit {
        this._storage = __cjbind_write_VArray_UInt8__3__from_VArray_UInt8__3_(this._storage, val)
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<color>()
        if (size != 3) {
            throw Exception("Size of color is not 3 but ${size} bytes")
        }
        let align = alignOf<color>()
        if (align != 1) {
            throw Exception("Alignment of color is not 1 but ${align} bytes")
        }
}
