package cjbind_ffi

@C
public struct TEST_STRUCT {
    public var ptr_32bit: UInt32
    public init(ptr_32bit: UInt32) {
        this.ptr_32bit = ptr_32bit
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TEST_STRUCT>()
        if (size != 4) {
            throw Exception("Size of TEST_STRUCT is not 4 but ${size} bytes")
        }
        let align = alignOf<TEST_STRUCT>()
        if (align != 4) {
            throw Exception("Alignment of TEST_STRUCT is not 4 but ${align} bytes")
        }
}

public type TEST = TEST_STRUCT
