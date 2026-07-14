package cjbind_ffi

@C
public struct ExternalHandle_ExternalHandle {
    public let value: ExternalPtr_ExternalPtr
    public init(value: ExternalPtr_ExternalPtr) {
        this.value = value
    }
}

@C
public struct NestedHolder_open0_int_close0_NestedHolder_open0_int_close0 {
    public let value: Int32
    public func clone(): NestedHolder_open0_int_close0_NestedHolder_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "NestedHolder_open0_int_close0_NestedHolder_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@C
public struct BlocklistedNestedArgumentHolder_BlocklistedNestedArgumentHolder {
    public let value: ExternalHandle_ExternalHandle
    public init(value: ExternalHandle_ExternalHandle) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BlocklistedNestedArgumentHolder_BlocklistedNestedArgumentHolder>()
        if (size != 1) {
            throw Exception(
                "Size of BlocklistedNestedArgumentHolder_BlocklistedNestedArgumentHolder is not 1 but ${size} bytes")
        }
        let align = alignOf<BlocklistedNestedArgumentHolder_BlocklistedNestedArgumentHolder>()
        if (align != 1) {
            throw Exception(
                "Alignment of BlocklistedNestedArgumentHolder_BlocklistedNestedArgumentHolder is not 1 but ${align} bytes")
        }
}
