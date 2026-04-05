package cjbind_ffi

public type void_fn_void_fn = CFunc<() -> Unit>

public type fn_fn = CFunc<(id: Int32) -> void_fn_void_fn>