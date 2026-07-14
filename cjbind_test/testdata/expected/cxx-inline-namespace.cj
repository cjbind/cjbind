package cjbind_ffi

@C
public struct api_Item_Item {
    public let value: Int32
    public func clone(): api_Item_Item {
        return this
    }
    public func toString(): String {
        var output = "api_Item_Item {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<api_Item_Item>()
        if (size != 4) {
            throw Exception("Size of api_Item_Item is not 4 but ${size} bytes")
        }
        let align = alignOf<api_Item_Item>()
        if (align != 4) {
            throw Exception("Alignment of api_Item_Item is not 4 but ${align} bytes")
        }
}

foreign func _ZN3api2v14pingENS0_4ItemE(input: api_Item_Item): Int32

public unsafe func api_ping(input: api_Item_Item): Int32 {
    return _ZN3api2v14pingENS0_4ItemE(input)
}
