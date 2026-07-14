package cjbind_ffi

@C
public struct ranges_v1_detail_Value_Value {
    public let value: Int32
    public func clone(): ranges_v1_detail_Value_Value {
        return this
    }
    public func toString(): String {
        var output = "ranges_v1_detail_Value_Value {"
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
        let size = sizeOf<ranges_v1_detail_Value_Value>()
        if (size != 4) {
            throw Exception("Size of ranges_v1_detail_Value_Value is not 4 but ${size} bytes")
        }
        let align = alignOf<ranges_v1_detail_Value_Value>()
        if (align != 4) {
            throw Exception("Alignment of ranges_v1_detail_Value_Value is not 4 but ${align} bytes")
        }
}
