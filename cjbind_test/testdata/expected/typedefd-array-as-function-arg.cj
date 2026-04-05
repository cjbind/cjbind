package cjbind_ffi

public type myVector3_myVector3 = VArray<Float32, $3>

foreign func modifyVectorFunc(v: CPointer<Float32>): Unit