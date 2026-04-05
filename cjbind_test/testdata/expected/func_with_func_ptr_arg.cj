package cjbind_ffi

foreign func foo(bar: CFunc<() -> Unit>): Unit

foreign func bar(one: CFunc<(a: Int32, b: Int32) -> Unit>, two: CFunc<(c: Int32, d: Int32) -> Unit>): Unit