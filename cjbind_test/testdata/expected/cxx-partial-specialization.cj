package cjbind_ffi

@C
public struct PartialHolder_Storage_open0_int_close0_Storage_open0_int_close0 {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PartialHolder_Storage_open0_int_close0_Storage_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of PartialHolder_Storage_open0_int_close0_Storage_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<PartialHolder_Storage_open0_int_close0_Storage_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of PartialHolder_Storage_open0_int_close0_Storage_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct PartialHolder_PartialHolder {
    public let scalar: PartialHolder_Storage_open0_int_close0_Storage_open0_int_close0
    public let pointers: VArray<UInt64, $2>
    public init(scalar: PartialHolder_Storage_open0_int_close0_Storage_open0_int_close0, pointers: VArray<UInt64, $2>) {
        this.scalar = scalar
        this.pointers = pointers
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PartialHolder_PartialHolder>()
        if (size != 24) {
            throw Exception("Size of PartialHolder_PartialHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<PartialHolder_PartialHolder>()
        if (align != 8) {
            throw Exception("Alignment of PartialHolder_PartialHolder is not 8 but ${align} bytes")
        }
}
