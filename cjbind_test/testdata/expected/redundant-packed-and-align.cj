package cjbind_ffi

@C
public struct redundant_packed {
    let _cjbind_opaque_blob: UInt64
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<redundant_packed>()
        if (size != 8) {
            throw Exception("Size of redundant_packed is not 8 but ${size} bytes")
        }
        let align = alignOf<redundant_packed>()
        if (align != 8) {
            throw Exception("Alignment of redundant_packed is not 8 but ${align} bytes")
        }
}

@C
public struct redundant_packed_bitfield {
    let _cjbind_opaque_blob: UInt64
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<redundant_packed_bitfield>()
        if (size != 8) {
            throw Exception("Size of redundant_packed_bitfield is not 8 but ${size} bytes")
        }
        let align = alignOf<redundant_packed_bitfield>()
        if (align != 8) {
            throw Exception("Alignment of redundant_packed_bitfield is not 8 but ${align} bytes")
        }
}

@C
public struct redundant_packed_union {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}

@C
public struct inner {
    let _cjbind_opaque_blob: UInt16
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt16>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<inner>()
        if (size != 2) {
            throw Exception("Size of inner is not 2 but ${size} bytes")
        }
        let align = alignOf<inner>()
        if (align != 2) {
            throw Exception("Alignment of inner is not 2 but ${align} bytes")
        }
}

@C
public struct outer_redundant_packed {
    let _cjbind_opaque_blob: UInt64
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<outer_redundant_packed>()
        if (size != 8) {
            throw Exception("Size of outer_redundant_packed is not 8 but ${size} bytes")
        }
        let align = alignOf<outer_redundant_packed>()
        if (align != 8) {
            throw Exception("Alignment of outer_redundant_packed is not 8 but ${align} bytes")
        }
}

@C
public struct redundant_pragma_packed {
    public var a: UInt8
    public var b: UInt16
    public init(a: UInt8, b: UInt16) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<redundant_pragma_packed>()
        if (size != 4) {
            throw Exception("Size of redundant_pragma_packed is not 4 but ${size} bytes")
        }
        let align = alignOf<redundant_pragma_packed>()
        if (align != 4) {
            throw Exception("Alignment of redundant_pragma_packed is not 4 but ${align} bytes")
        }
}
