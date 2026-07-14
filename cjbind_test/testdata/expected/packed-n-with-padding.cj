package cjbind_ffi

@C
public struct Packed {
    let _cjbind_opaque_blob: VArray<UInt16, $5>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Packed>()
        if (size != 10) {
            throw Exception("Size of Packed is not 10 but ${size} bytes")
        }
        let align = alignOf<Packed>()
        if (align != 2) {
            throw Exception("Alignment of Packed is not 2 but ${align} bytes")
        }
}

@C
public struct PackedLongWithChars {
    let _cjbind_opaque_blob: VArray<UInt16, $6>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $6>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedLongWithChars>()
        if (size != 12) {
            throw Exception("Size of PackedLongWithChars is not 12 but ${size} bytes")
        }
        let align = alignOf<PackedLongWithChars>()
        if (align != 2) {
            throw Exception("Alignment of PackedLongWithChars is not 2 but ${align} bytes")
        }
}
