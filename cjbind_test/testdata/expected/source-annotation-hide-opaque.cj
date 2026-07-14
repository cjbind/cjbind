package cjbind_ffi

// <div cjbind opaque></div> *
@C
public struct SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord {
    let _cjbind_opaque_blob: UInt32
    public func clone(): SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord {
        return this
    }
    public func toString(): String {
        var output = "SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord>()
        if (size != 4) {
            throw Exception(
                "Size of SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord is not 4 but ${size} bytes")
        }
        let align = alignOf<SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord>()
        if (align != 4) {
            throw Exception(
                "Alignment of SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord is not 4 but ${align} bytes")
        }
}

@C
public struct SourceAnnotationOpaqueReference_SourceAnnotationOpaqueReference {
    public let value: CPointer<SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord>
    public func clone(): SourceAnnotationOpaqueReference_SourceAnnotationOpaqueReference {
        return this
    }
    public func toString(): String {
        var output = "SourceAnnotationOpaqueReference_SourceAnnotationOpaqueReference {"
        output += " value: "
        output += CPointer<Unit>(this.value).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(value: CPointer<SourceAnnotationOpaqueRecord_SourceAnnotationOpaqueRecord>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SourceAnnotationOpaqueReference_SourceAnnotationOpaqueReference>()
        if (size != 8) {
            throw Exception(
                "Size of SourceAnnotationOpaqueReference_SourceAnnotationOpaqueReference is not 8 but ${size} bytes")
        }
        let align = alignOf<SourceAnnotationOpaqueReference_SourceAnnotationOpaqueReference>()
        if (align != 8) {
            throw Exception(
                "Alignment of SourceAnnotationOpaqueReference_SourceAnnotationOpaqueReference is not 8 but ${align} bytes")
        }
}
