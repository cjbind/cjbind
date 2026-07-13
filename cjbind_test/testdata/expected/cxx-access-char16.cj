package cjbind_ffi

public type cjbind_cchar16_t = UInt16

public const Color_Red: Color_Color = 1
public const Color_Blue: Color_Color = 2

public type Color_Color = UInt16

public const Access_Answer_Answer: Int32 = 42

@C
public struct Access_Visible_Visible {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Access_Visible_Visible>()
        if (size != 4) {
            throw Exception("Size of Access_Visible_Visible is not 4 but ${size} bytes")
        }
        let align = alignOf<Access_Visible_Visible>()
        if (align != 4) {
            throw Exception("Alignment of Access_Visible_Visible is not 4 but ${align} bytes")
        }
}

@C
public struct Access_Access {
    public let open_: Int32
    private let guarded: Int16
    private let code: cjbind_cchar16_t
    private init(open_: Int32, guarded: Int16, code: cjbind_cchar16_t) {
        this.open_ = open_
        this.guarded = guarded
        this.code = code
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Access_Access>()
        if (size != 8) {
            throw Exception("Size of Access_Access is not 8 but ${size} bytes")
        }
        let align = alignOf<Access_Access>()
        if (align != 4) {
            throw Exception("Alignment of Access_Access is not 4 but ${align} bytes")
        }
}

@C
public struct Packed_Packed {
    let _cjbind_opaque_blob: VArray<UInt8, $5>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Packed_Packed>()
        if (size != 5) {
            throw Exception("Size of Packed_Packed is not 5 but ${size} bytes")
        }
        let align = alignOf<Packed_Packed>()
        if (align != 1) {
            throw Exception("Alignment of Packed_Packed is not 1 but ${align} bytes")
        }
}
