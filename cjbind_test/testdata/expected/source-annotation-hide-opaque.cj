package cjbind_ffi

public const SourceAnnotationVariantHide_SourceAnnotationVisibleVariant: SourceAnnotationVariantHide = 0
public const SourceAnnotationVariantHide_SourceAnnotationFollowingVariant: SourceAnnotationVariantHide = 2

public type SourceAnnotationVariantHide = UInt32

// <div cjbind opaque>Opaque record documentation.</div> *
@C
public struct SourceAnnotationOpaqueRecord {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SourceAnnotationOpaqueRecord>()
        if (size != 4) {
            throw Exception("Size of SourceAnnotationOpaqueRecord is not 4 but ${size} bytes")
        }
        let align = alignOf<SourceAnnotationOpaqueRecord>()
        if (align != 4) {
            throw Exception("Alignment of SourceAnnotationOpaqueRecord is not 4 but ${align} bytes")
        }
}

@C
public struct SourceAnnotationOpaqueReference {
    public let value: CPointer<SourceAnnotationOpaqueRecord>
    public init(value: CPointer<SourceAnnotationOpaqueRecord>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SourceAnnotationOpaqueReference>()
        if (size != 8) {
            throw Exception("Size of SourceAnnotationOpaqueReference is not 8 but ${size} bytes")
        }
        let align = alignOf<SourceAnnotationOpaqueReference>()
        if (align != 8) {
            throw Exception("Alignment of SourceAnnotationOpaqueReference is not 8 but ${align} bytes")
        }
}
