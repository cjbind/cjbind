@C
func __cjbind_read_UInt32(ptr: CPointer<UInt8>): UInt32 {
    return unsafe { CPointer<UInt32>(ptr).read() }
}

@C
func __cjbind_write_UInt32(ptr: CPointer<UInt8>, val: UInt32): Unit {
    unsafe { CPointer<UInt32>(ptr).write(val) }
}

@C
func __cjbind_read_foo__cjbind_ty_1(ptr: CPointer<UInt8>): foo__cjbind_ty_1 {
    return unsafe { CPointer<foo__cjbind_ty_1>(ptr).read() }
}

@C
func __cjbind_write_foo__cjbind_ty_1(ptr: CPointer<UInt8>, val: foo__cjbind_ty_1): Unit {
    unsafe { CPointer<foo__cjbind_ty_1>(ptr).write(val) }
}

@C
func __cjbind_read_foo__cjbind_ty_2(ptr: CPointer<UInt8>): foo__cjbind_ty_2 {
    return unsafe { CPointer<foo__cjbind_ty_2>(ptr).read() }
}

@C
func __cjbind_write_foo__cjbind_ty_2(ptr: CPointer<UInt8>, val: foo__cjbind_ty_2): Unit {
    unsafe { CPointer<foo__cjbind_ty_2>(ptr).write(val) }
}

package cjbind_ffi

@C
public struct foo__cjbind_ty_1 {
public let c1 : UInt16
public let c2 : UInt16
public init(c1 : UInt16, c2 : UInt16) {
    this.c1 = c1
this.c2 = c2
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<foo__cjbind_ty_1>()
    if (size != 4) {
        throw Exception("Size of foo__cjbind_ty_1 is not 4 but ${size} bytes")
    }
    let align = alignOf<foo__cjbind_ty_1>()
    if (align != 2) {
        throw Exception("Alignment of foo__cjbind_ty_1 is not 2 but ${align} bytes")
    }
}

@C
public struct foo__cjbind_ty_2 {
public let d1 : UInt8
public let d2 : UInt8
public let d3 : UInt8
public let d4 : UInt8
public init(d1 : UInt8, d2 : UInt8, d3 : UInt8, d4 : UInt8) {
    this.d1 = d1
this.d2 = d2
this.d3 = d3
this.d4 = d4
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<foo__cjbind_ty_2>()
    if (size != 4) {
        throw Exception("Size of foo__cjbind_ty_2 is not 4 but ${size} bytes")
    }
    let align = alignOf<foo__cjbind_ty_2>()
    if (align != 1) {
        throw Exception("Alignment of foo__cjbind_ty_2 is not 1 but ${align} bytes")
    }
}

@C
public struct foo__cjbind_ty_1 {
var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
public init() {}
public func b(): UInt32 {
    var s = this._storage
    return unsafe { __cjbind_read_UInt32(CPointer<UInt8>(inout s)) }
}
public mut func b(val!: UInt32): Unit {
    unsafe { __cjbind_write_UInt32(CPointer<UInt8>(inout this._storage), val) }
}
public func __cjbind_anon_1(): foo__cjbind_ty_1 {
    var s = this._storage
    return unsafe { __cjbind_read_foo__cjbind_ty_1(CPointer<UInt8>(inout s)) }
}
public mut func __cjbind_anon_1(val!: foo__cjbind_ty_1): Unit {
    unsafe { __cjbind_write_foo__cjbind_ty_1(CPointer<UInt8>(inout this._storage), val) }
}
public func __cjbind_anon_2(): foo__cjbind_ty_2 {
    var s = this._storage
    return unsafe { __cjbind_read_foo__cjbind_ty_2(CPointer<UInt8>(inout s)) }
}
public mut func __cjbind_anon_2(val!: foo__cjbind_ty_2): Unit {
    unsafe { __cjbind_write_foo__cjbind_ty_2(CPointer<UInt8>(inout this._storage), val) }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<foo__cjbind_ty_1>()
    if (size != 4) {
        throw Exception("Size of foo__cjbind_ty_1 is not 4 but ${size} bytes")
    }
    let align = alignOf<foo__cjbind_ty_1>()
    if (align != 4) {
        throw Exception("Alignment of foo__cjbind_ty_1 is not 4 but ${align} bytes")
    }
}

@C
public struct foo_foo {
public let a : UInt32
public let __cjbind_anon_1 : foo__cjbind_ty_1
public init(a : UInt32, __cjbind_anon_1 : foo__cjbind_ty_1) {
    this.a = a
this.__cjbind_anon_1 = __cjbind_anon_1
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<foo_foo>()
    if (size != 8) {
        throw Exception("Size of foo_foo is not 8 but ${size} bytes")
    }
    let align = alignOf<foo_foo>()
    if (align != 4) {
        throw Exception("Alignment of foo_foo is not 4 but ${align} bytes")
    }
}