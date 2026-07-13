package cjbind_ffi

// This should not be opaque; we can see the attributes and can pack the
// struct.
@C
public struct AlignedToOne_AlignedToOne {
    let _cjbind_opaque_blob: VArray<UInt8, $4>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AlignedToOne_AlignedToOne>()
        if (size != 4) {
            throw Exception("Size of AlignedToOne_AlignedToOne is not 4 but ${size} bytes")
        }
        let align = alignOf<AlignedToOne_AlignedToOne>()
        if (align != 1) {
            throw Exception("Alignment of AlignedToOne_AlignedToOne is not 1 but ${align} bytes")
        }
}

// This should be opaque because although we can see the attributes, Rust before
// 1.33 doesn't have `#[repr(packed(N))]`.
@C
public struct AlignedToTwo_AlignedToTwo {
    let _cjbind_opaque_blob: VArray<UInt16, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<AlignedToTwo_AlignedToTwo>()
        if (size != 4) {
            throw Exception("Size of AlignedToTwo_AlignedToTwo is not 4 but ${size} bytes")
        }
        let align = alignOf<AlignedToTwo_AlignedToTwo>()
        if (align != 2) {
            throw Exception("Alignment of AlignedToTwo_AlignedToTwo is not 2 but ${align} bytes")
        }
}

// This should not be opaque because although `libclang` doesn't give us the
// `#pragma pack(1)`, we can detect that alignment is 1 and add
// `#[repr(packed)]` to the struct ourselves.
@C
public struct PackedToOne_PackedToOne {
    let _cjbind_opaque_blob: VArray<UInt8, $8>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $8>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedToOne_PackedToOne>()
        if (size != 8) {
            throw Exception("Size of PackedToOne_PackedToOne is not 8 but ${size} bytes")
        }
        let align = alignOf<PackedToOne_PackedToOne>()
        if (align != 1) {
            throw Exception("Alignment of PackedToOne_PackedToOne is not 1 but ${align} bytes")
        }
}

// In this case, even if we can detect the weird alignment triggered by
// `#pragma pack(2)`, we can't do anything about it because Rust before 1.33
// doesn't have `#[repr(packed(N))]`. Therefore, we must make it opaque.
@C
public struct PackedToTwo_PackedToTwo {
    let _cjbind_opaque_blob: VArray<UInt16, $4>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt16, $4>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PackedToTwo_PackedToTwo>()
        if (size != 8) {
            throw Exception("Size of PackedToTwo_PackedToTwo is not 8 but ${size} bytes")
        }
        let align = alignOf<PackedToTwo_PackedToTwo>()
        if (align != 2) {
            throw Exception("Alignment of PackedToTwo_PackedToTwo is not 2 but ${align} bytes")
        }
}
