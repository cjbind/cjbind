package cjbind_ffi

public type InternalAlias = InternalRecord

@C
public struct PublicRecord {
    public let internal_: CPointer<InternalRecord>
    public let aliased: CPointer<InternalAlias>
    public init(internal_: CPointer<InternalRecord>, aliased: CPointer<InternalAlias>) {
        this.internal_ = internal_
        this.aliased = aliased
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PublicRecord>()
        if (size != 16) {
            throw Exception("Size of PublicRecord is not 16 but ${size} bytes")
        }
        let align = alignOf<PublicRecord>()
        if (align != 8) {
            throw Exception("Alignment of PublicRecord is not 8 but ${align} bytes")
        }
}
