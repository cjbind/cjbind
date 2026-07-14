package cjbind_ffi

// Packed records use opaque storage because the current Cangjie FFI cannot
// declare packed field layout directly.
@C
public struct AlignedToOne_AlignedToOne {
    let _cjbind_opaque_blob: VArray<UInt8, $4>
    public func clone(): AlignedToOne_AlignedToOne {
        return this
    }
    public func toString(): String {
        var output = "AlignedToOne_AlignedToOne {"
        output += " <opaque>"
        output += " }"
        return output
    }
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

// The opaque storage must preserve the explicit two-byte alignment.
@C
public struct AlignedToTwo_AlignedToTwo {
    let _cjbind_opaque_blob: VArray<UInt16, $2>
    public func clone(): AlignedToTwo_AlignedToTwo {
        return this
    }
    public func toString(): String {
        var output = "AlignedToTwo_AlignedToTwo {"
        output += " <opaque>"
        output += " }"
        return output
    }
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

// The translation unit reports the effective one-byte alignment even though
// the packing directive is not attached to the record cursor.
@C
public struct PackedToOne_PackedToOne {
    let _cjbind_opaque_blob: VArray<UInt8, $8>
    public func clone(): PackedToOne_PackedToOne {
        return this
    }
    public func toString(): String {
        var output = "PackedToOne_PackedToOne {"
        output += " <opaque>"
        output += " }"
        return output
    }
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

// The opaque storage must preserve the two-byte alignment introduced by the
// packing directive.
@C
public struct PackedToTwo_PackedToTwo {
    let _cjbind_opaque_blob: VArray<UInt16, $4>
    public func clone(): PackedToTwo_PackedToTwo {
        return this
    }
    public func toString(): String {
        var output = "PackedToTwo_PackedToTwo {"
        output += " <opaque>"
        output += " }"
        return output
    }
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
