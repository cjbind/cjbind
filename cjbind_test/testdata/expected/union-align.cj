@C
func __cjbind_read_UInt8(ptr: CPointer<UInt8>): UInt8 {
    return unsafe { CPointer<UInt8>(ptr).read() }
}

@C
func __cjbind_write_UInt8(ptr: CPointer<UInt8>, val: UInt8): Unit {
    unsafe { CPointer<UInt8>(ptr).write(val) }
}

@C
func __cjbind_read_Bar_Bar(ptr: CPointer<UInt8>): Bar_Bar {
    return unsafe { CPointer<Bar_Bar>(ptr).read() }
}

@C
func __cjbind_write_Bar_Bar(ptr: CPointer<UInt8>, val: Bar_Bar): Unit {
    unsafe { CPointer<Bar_Bar>(ptr).write(val) }
}

package cjbind_ffi

@C
public struct Bar_Bar {
var _storage: VArray<UInt8, $16> = unsafe { zeroValue<VArray<UInt8, $16>>() }
public init() {}
public func foo(): UInt8 {
    var s = this._storage
    return unsafe { __cjbind_read_UInt8(CPointer<UInt8>(inout s)) }
}
public mut func foo(val!: UInt8): Unit {
    unsafe { __cjbind_write_UInt8(CPointer<UInt8>(inout this._storage), val) }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<Bar_Bar>()
    if (size != 16) {
        throw Exception("Size of Bar_Bar is not 16 but ${size} bytes")
    }
    let align = alignOf<Bar_Bar>()
    if (align != 16) {
        throw Exception("Alignment of Bar_Bar is not 16 but ${align} bytes")
    }
}

@C
public struct Baz_Baz {
var _storage: VArray<UInt8, $16> = unsafe { zeroValue<VArray<UInt8, $16>>() }
public init() {}
public func bar(): Bar_Bar {
    var s = this._storage
    return unsafe { __cjbind_read_Bar_Bar(CPointer<UInt8>(inout s)) }
}
public mut func bar(val!: Bar_Bar): Unit {
    unsafe { __cjbind_write_Bar_Bar(CPointer<UInt8>(inout this._storage), val) }
}
}

@When[debug]
let _ = {
=>
    let size = sizeOf<Baz_Baz>()
    if (size != 16) {
        throw Exception("Size of Baz_Baz is not 16 but ${size} bytes")
    }
    let align = alignOf<Baz_Baz>()
    if (align != 16) {
        throw Exception("Alignment of Baz_Baz is not 16 but ${align} bytes")
    }
}