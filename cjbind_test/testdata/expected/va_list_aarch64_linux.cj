package cjbind_ffi

public type va_list_va_list = __builtin_va_list___builtin_va_list

foreign func vprintf(format: CPointer<UInt8>, vlist: __builtin_va_list___builtin_va_list): Int32

public type __builtin_va_list___builtin_va_list = CPointer<UInt8>