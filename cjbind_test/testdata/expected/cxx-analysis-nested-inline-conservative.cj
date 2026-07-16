package cjbind_ffi

@C
public struct ranges_v1_detail_Value {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ranges_v1_detail_Value>()
        if (size != 4) {
            throw Exception("Size of ranges_v1_detail_Value is not 4 but ${size} bytes")
        }
        let align = alignOf<ranges_v1_detail_Value>()
        if (align != 4) {
            throw Exception("Alignment of ranges_v1_detail_Value is not 4 but ${align} bytes")
        }
}
