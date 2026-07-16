package cjbind_ffi

// ABI-only opaque pointer for a C variadic callback. The generic arguments document the source signature; this alias is not callable from Cangjie.
public type __CjbindVariadicFunction3<R, A0, A1, A2> = CPointer<Unit>

foreign func f(a: Int32, ...): Unit

@C
public struct Foo {
    public var f: __CjbindVariadicFunction3<Unit, CPointer<Unit>, CPointer<Unit>, Int32>
    public init(f: __CjbindVariadicFunction3<Unit, CPointer<Unit>, CPointer<Unit>, Int32>) {
        this.f = f
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Foo>()
        if (size != 8) {
            throw Exception("Size of Foo is not 8 but ${size} bytes")
        }
        let align = alignOf<Foo>()
        if (align != 8) {
            throw Exception("Alignment of Foo is not 8 but ${align} bytes")
        }
}
