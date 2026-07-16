package cjbind_ffi

@C
public struct BlocklistedNestedArgumentHolder {
    public let value: UInt8
    private init(value: UInt8) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BlocklistedNestedArgumentHolder>()
        if (size != 1) {
            throw Exception("Size of BlocklistedNestedArgumentHolder is not 1 but ${size} bytes")
        }
        let align = alignOf<BlocklistedNestedArgumentHolder>()
        if (align != 1) {
            throw Exception("Alignment of BlocklistedNestedArgumentHolder is not 1 but ${align} bytes")
        }
}

@C
public struct BlocklistedPointerHolder {
    public var value: CPointer<UInt8>
    private init(value: CPointer<UInt8>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BlocklistedPointerHolder>()
        if (size != 8) {
            throw Exception("Size of BlocklistedPointerHolder is not 8 but ${size} bytes")
        }
        let align = alignOf<BlocklistedPointerHolder>()
        if (align != 8) {
            throw Exception("Alignment of BlocklistedPointerHolder is not 8 but ${align} bytes")
        }
}
