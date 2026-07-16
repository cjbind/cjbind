package cjbind_ffi

// ABI-only opaque pointer for a C variadic callback. The generic arguments document the source signature; this alias is not callable from Cangjie.
public type __CjbindVariadicFunction0<R> = CPointer<Unit>

foreign func foo(bar: __CjbindVariadicFunction0<Unit>): Unit

foreign func bar(one: CFunc<(a: Int32, b: Int32) -> Unit>, two: CFunc<(c: Int32, d: Int32) -> Unit>): Unit
