package cjbind_ffi

public type FuncType = CFunc<() -> Unit>

foreign func Func(): Unit
