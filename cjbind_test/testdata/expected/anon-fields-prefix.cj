@C
func __cjbind_read_color__cjbind_ty_1(ptr: CPointer<UInt8>): color__cjbind_ty_1 {
    return unsafe { CPointer<color__cjbind_ty_1>(ptr).read() }
}

@C
func __cjbind_write_color__cjbind_ty_1(ptr: CPointer<UInt8>, val: color__cjbind_ty_1): Unit {
    unsafe { CPointer<color__cjbind_ty_1>(ptr).write(val) }
}

@C
func __cjbind_read_color__cjbind_ty_2(ptr: CPointer<UInt8>): color__cjbind_ty_2 {
    return unsafe { CPointer<color__cjbind_ty_2>(ptr).read() }
}

@C
func __cjbind_write_color__cjbind_ty_2(ptr: CPointer<UInt8>, val: color__cjbind_ty_2): Unit {
    unsafe { CPointer<color__cjbind_ty_2>(ptr).write(val) }
}

@C
func __cjbind_read_VArray<UInt8,$3>(ptr: CPointer<UInt8>): VArray<UInt8, $3> {
    return unsafe { CPointer<VArray<UInt8, $3>>(ptr).read() }
}

@C
func __cjbind_write_VArray<UInt8,$3>(ptr: CPointer<UInt8>, val: VArray<UInt8, $3>): Unit {
    unsafe { CPointer<VArray<UInt8, $3>>(ptr).write(val) }
}

package cjbind_ffi

@C
public struct color__cjbind_ty_1 {
public let r : UInt8
public let g : UInt8
public let b : UInt8
public init(r : UInt8 , g : UInt8 , b : UInt8) {
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
public let y : UInt8
public let u : UInt8
public let v : UInt8
public init(y : UInt8 , u : UInt8 , v : UInt8) {
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
public struct color_color {
var _storage: VArray<UInt8, $3> = unsafe { zeroValue<VArray<UInt8, $3>>() }
public init() {}
public func __cjbind_anon_1(): color__cjbind_ty_1 {
    var s = this._storage
    return unsafe { __cjbind_read_color__cjbind_ty_1(CPointer<UInt8>(inout s)) }
}
public mut func __cjbind_anon_1(val!: color__cjbind_ty_1): Unit {
    unsafe { __cjbind_write_color__cjbind_ty_1(CPointer<UInt8>(inout this._storage), val) }
}
public func __cjbind_anon_2(): color__cjbind_ty_2 {
    var s = this._storage
    return unsafe { __cjbind_read_color__cjbind_ty_2(CPointer<UInt8>(inout s)) }
}
public mut func __cjbind_anon_2(val!: color__cjbind_ty_2): Unit {
    unsafe { __cjbind_write_color__cjbind_ty_2(CPointer<UInt8>(inout this._storage), val) }
}
public func v3(): VArray<UInt8, $3> {
    var s = this._storage
    return unsafe { __cjbind_read_VArray<UInt8,$3>(CPointer<UInt8>(inout s)) }
}
public mut func v3(val!: VArray<UInt8, $3>): Unit {
    unsafe { __cjbind_write_VArray<UInt8,$3>(CPointer<UInt8>(inout this._storage), val) }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<color_color>()
    if (size != 3) {
        throw Exception("Size of color_color is not 3 but ${size} bytes")
    }
    let align = alignOf<color_color>()
    if (align != 1) {
        throw Exception("Alignment of color_color is not 1 but ${align} bytes")
    }
}