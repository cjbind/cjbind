package cjbind_ffi

public type va_list_va_list = VArray<UInt64, $4>

foreign func vprintf(format: CPointer<UInt8>, vlist: VArray<UInt64, $4>): Int32
