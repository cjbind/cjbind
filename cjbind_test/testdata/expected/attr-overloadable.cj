package cjbind_ffi

foreign func _Z11my_functioni(a: Int32): Unit

public unsafe func my_function(a: Int32): Unit {
    return _Z11my_functioni(a)
}

foreign func _Z11my_functionPKc(a: CPointer<UInt8>): Unit

public unsafe func my_function1(a: CPointer<UInt8>): Unit {
    return _Z11my_functionPKc(a)
}
