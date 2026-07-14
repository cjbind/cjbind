package cjbind_ffi

@C
public struct redundant_packed_redundant_packed {
    let _cjbind_opaque_blob: UInt64
    public func clone(): redundant_packed_redundant_packed {
        return this
    }
    public func toString(): String {
        var output = "redundant_packed_redundant_packed {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<redundant_packed_redundant_packed>()
        if (size != 8) {
            throw Exception("Size of redundant_packed_redundant_packed is not 8 but ${size} bytes")
        }
        let align = alignOf<redundant_packed_redundant_packed>()
        if (align != 8) {
            throw Exception("Alignment of redundant_packed_redundant_packed is not 8 but ${align} bytes")
        }
}

@C
public struct redundant_packed_bitfield_redundant_packed_bitfield {
    let _cjbind_opaque_blob: UInt64
    public func clone(): redundant_packed_bitfield_redundant_packed_bitfield {
        return this
    }
    public func toString(): String {
        var output = "redundant_packed_bitfield_redundant_packed_bitfield {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<redundant_packed_bitfield_redundant_packed_bitfield>()
        if (size != 8) {
            throw Exception("Size of redundant_packed_bitfield_redundant_packed_bitfield is not 8 but ${size} bytes")
        }
        let align = alignOf<redundant_packed_bitfield_redundant_packed_bitfield>()
        if (align != 8) {
            throw Exception(
                "Alignment of redundant_packed_bitfield_redundant_packed_bitfield is not 8 but ${align} bytes")
        }
}

@C
public struct redundant_packed_union_redundant_packed_union {
    let _cjbind_opaque_blob: VArray<UInt8, $16>
    public func clone(): redundant_packed_union_redundant_packed_union {
        return this
    }
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $16>>() }
    }
}

@C
public struct inner_inner {
    let _cjbind_opaque_blob: UInt16
    public func clone(): inner_inner {
        return this
    }
    public func toString(): String {
        var output = "inner_inner {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt16>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<inner_inner>()
        if (size != 2) {
            throw Exception("Size of inner_inner is not 2 but ${size} bytes")
        }
        let align = alignOf<inner_inner>()
        if (align != 2) {
            throw Exception("Alignment of inner_inner is not 2 but ${align} bytes")
        }
}

@C
public struct outer_redundant_packed_outer_redundant_packed {
    let _cjbind_opaque_blob: UInt64
    public func clone(): outer_redundant_packed_outer_redundant_packed {
        return this
    }
    public func toString(): String {
        var output = "outer_redundant_packed_outer_redundant_packed {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt64>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<outer_redundant_packed_outer_redundant_packed>()
        if (size != 8) {
            throw Exception("Size of outer_redundant_packed_outer_redundant_packed is not 8 but ${size} bytes")
        }
        let align = alignOf<outer_redundant_packed_outer_redundant_packed>()
        if (align != 8) {
            throw Exception("Alignment of outer_redundant_packed_outer_redundant_packed is not 8 but ${align} bytes")
        }
}

@C
public struct redundant_pragma_packed_redundant_pragma_packed {
    public let a: UInt8
    public let b: UInt16
    public func clone(): redundant_pragma_packed_redundant_pragma_packed {
        return this
    }
    public func toString(): String {
        var output = "redundant_pragma_packed_redundant_pragma_packed {"
        output += " a: "
        output += this.a.toString()
        output += ", b: "
        output += this.b.toString()
        output += " }"
        return output
    }
    public init(a: UInt8, b: UInt16) {
        this.a = a
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<redundant_pragma_packed_redundant_pragma_packed>()
        if (size != 4) {
            throw Exception("Size of redundant_pragma_packed_redundant_pragma_packed is not 4 but ${size} bytes")
        }
        let align = alignOf<redundant_pragma_packed_redundant_pragma_packed>()
        if (align != 4) {
            throw Exception("Alignment of redundant_pragma_packed_redundant_pragma_packed is not 4 but ${align} bytes")
        }
}
