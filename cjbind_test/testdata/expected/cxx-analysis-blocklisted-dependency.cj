package cjbind_ffi

@C
public struct PublicRecord_PublicRecord {
    public let internal_: CPointer<InternalRecord_InternalRecord>
    public func clone(): PublicRecord_PublicRecord {
        return this
    }
    public func toString(): String {
        var output = "PublicRecord_PublicRecord {"
        output += " internal: "
        output += CPointer<Unit>(this.internal_).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(internal_: CPointer<InternalRecord_InternalRecord>) {
        this.internal_ = internal_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PublicRecord_PublicRecord>()
        if (size != 8) {
            throw Exception("Size of PublicRecord_PublicRecord is not 8 but ${size} bytes")
        }
        let align = alignOf<PublicRecord_PublicRecord>()
        if (align != 8) {
            throw Exception("Alignment of PublicRecord_PublicRecord is not 8 but ${align} bytes")
        }
}
