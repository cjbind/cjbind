package cjbind_ffi

@C
public struct api_Item {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<api_Item>()
        if (size != 4) {
            throw Exception("Size of api_Item is not 4 but ${size} bytes")
        }
        let align = alignOf<api_Item>()
        if (align != 4) {
            throw Exception("Alignment of api_Item is not 4 but ${align} bytes")
        }
}

foreign func _ZN3api2v14pingENS0_4ItemE(input: api_Item): Int32

public unsafe func api_ping(input: api_Item): Int32 {
    return _ZN3api2v14pingENS0_4ItemE(input)
}
