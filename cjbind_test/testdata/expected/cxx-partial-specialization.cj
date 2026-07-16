package cjbind_ffi

@C
public struct PartialHolder {
    public let scalar: Storage_open0_int_close0
    public let pointers: VArray<UInt64, $2>
    private init(scalar: Storage_open0_int_close0, pointers: VArray<UInt64, $2>) {
        this.scalar = scalar
        this.pointers = pointers
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PartialHolder>()
        if (size != 24) {
            throw Exception("Size of PartialHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<PartialHolder>()
        if (align != 8) {
            throw Exception("Alignment of PartialHolder is not 8 but ${align} bytes")
        }
}

@C
public struct Storage_open0_int_close0 {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Storage_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of Storage_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Storage_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of Storage_open0_int_close0 is not 4 but ${align} bytes")
        }
}
