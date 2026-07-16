package cjbind_ffi

// ABI-only opaque pointer for a C variadic callback. The generic arguments document the source signature; this alias is not callable from Cangjie.
public type __CjbindVariadicFunction0<R> = CPointer<Unit>

public type FuncType = __CjbindVariadicFunction0<Unit>

foreign func Func(): Unit
