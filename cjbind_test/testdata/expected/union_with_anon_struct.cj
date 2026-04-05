@C
func __cjbind_read_foo__cjbind_ty_1(ptr: CPointer<UInt8>): foo__cjbind_ty_1 {
    return unsafe { CPointer<foo__cjbind_ty_1>(ptr).read() }
}

@C
func __cjbind_write_foo__cjbind_ty_1(ptr: CPointer<UInt8>, val: foo__cjbind_ty_1): Unit {
    unsafe { CPointer<foo__cjbind_ty_1>(ptr).write(val) }
}

package cjbind_ffi

@C
public struct foo__cjbind_ty_1 {
public let a : UInt32
public let b : UInt32
public init(a : UInt32, b : UInt32) {
    this.a = a
this.b = b
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<foo__cjbind_ty_1>()
    if (size != 8) {
        throw Exception("Size of foo__cjbind_ty_1 is not 8 but ${size} bytes")
    }
    let align = alignOf<foo__cjbind_ty_1>()
    if (align != 4) {
        throw Exception("Alignment of foo__cjbind_ty_1 is not 4 but ${align} bytes")
    }
}

@C
public struct foo_foo {
var _storage: VArray<UInt32, $2> = unsafe { zeroValue<VArray<UInt32, $2>>() }
public init() {}
public func bar(): foo__cjbind_ty_1 {
    var s = this._storage
    return unsafe { __cjbind_read_foo__cjbind_ty_1(CPointer<UInt8>(inout s)) }
}
public mut func bar(val!: foo__cjbind_ty_1): Unit {
    unsafe { __cjbind_write_foo__cjbind_ty_1(CPointer<UInt8>(inout this._storage), val) }
}
public func __cjbind_anon_1(): foo__cjbind_ty_1 {
    var s = this._storage
    return unsafe { __cjbind_read_foo__cjbind_ty_1(CPointer<UInt8>(inout s)) }
}
public mut func __cjbind_anon_1(val!: foo__cjbind_ty_1): Unit {
    unsafe { __cjbind_write_foo__cjbind_ty_1(CPointer<UInt8>(inout this._storage), val) }
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