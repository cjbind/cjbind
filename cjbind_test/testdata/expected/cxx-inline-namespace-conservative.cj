package cjbind_ffi

@C
public struct api_v1_Item {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<api_v1_Item>()
        if (size != 4) {
            throw Exception("Size of api_v1_Item is not 4 but ${size} bytes")
        }
        let align = alignOf<api_v1_Item>()
        if (align != 4) {
            throw Exception("Alignment of api_v1_Item is not 4 but ${align} bytes")
        }
}

foreign func _ZN3api2v14pingENS0_4ItemE(input: api_v1_Item): Int32

public unsafe func api_v1_ping(input: api_v1_Item): Int32 {
    return _ZN3api2v14pingENS0_4ItemE(input)
}
