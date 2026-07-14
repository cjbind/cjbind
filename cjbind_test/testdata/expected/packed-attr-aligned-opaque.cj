package cjbind_ffi

// Packed records use opaque storage because the current Cangjie FFI cannot
// declare packed field layout directly.
@C
public struct AlignedToOne {
    let _cjbind_opaque_blob: VArray<UInt8, $4>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AlignedToOne>()
        if (size != 4) {
            throw Exception("Size of AlignedToOne is not 4 but ${size} bytes")
        }
        let align = alignOf<AlignedToOne>()
        if (align != 1) {
            throw Exception("Alignment of AlignedToOne is not 1 but ${align} bytes")
        }
}

// The opaque storage must preserve the explicit two-byte alignment.
@C
public struct AlignedToTwo {
    let _cjbind_opaque_blob: VArray<UInt16, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AlignedToTwo>()
        if (size != 4) {
            throw Exception("Size of AlignedToTwo is not 4 but ${size} bytes")
        }
        let align = alignOf<AlignedToTwo>()
        if (align != 2) {
            throw Exception("Alignment of AlignedToTwo is not 2 but ${align} bytes")
        }
}

// The translation unit reports the effective one-byte alignment even though
// the packing directive is not attached to the record cursor.
@C
public struct PackedToOne {
    let _cjbind_opaque_blob: VArray<UInt8, $8>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $8>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedToOne>()
        if (size != 8) {
            throw Exception("Size of PackedToOne is not 8 but ${size} bytes")
        }
        let align = alignOf<PackedToOne>()
        if (align != 1) {
            throw Exception("Alignment of PackedToOne is not 1 but ${align} bytes")
        }
}

// The opaque storage must preserve the two-byte alignment introduced by the
// packing directive.
@C
public struct PackedToTwo {
    let _cjbind_opaque_blob: VArray<UInt16, $4>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedToTwo>()
        if (size != 8) {
            throw Exception("Size of PackedToTwo is not 8 but ${size} bytes")
        }
        let align = alignOf<PackedToTwo>()
        if (align != 2) {
            throw Exception("Alignment of PackedToTwo is not 2 but ${align} bytes")
        }
}
