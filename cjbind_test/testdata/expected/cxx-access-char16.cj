package cjbind_ffi

public const Color_Red: Color = 1
public const Color_Blue: Color = 2

public type Color = UInt16

public const Access_Answer: Int32 = 42

@C
public struct Access_Visible {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Access_Visible>()
        if (size != 4) {
            throw Exception("Size of Access_Visible is not 4 but ${size} bytes")
        }
        let align = alignOf<Access_Visible>()
        if (align != 4) {
            throw Exception("Alignment of Access_Visible is not 4 but ${align} bytes")
        }
}

@C
public struct Access {
    public var open_: Int32
    private var guarded: Int16
    private var code: UInt16
    private init(open_: Int32, guarded: Int16, code: UInt16) {
        this.open_ = open_
        this.guarded = guarded
        this.code = code
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Access>()
        if (size != 8) {
            throw Exception("Size of Access is not 8 but ${size} bytes")
        }
        let align = alignOf<Access>()
        if (align != 4) {
            throw Exception("Alignment of Access is not 4 but ${align} bytes")
        }
}

@C
public struct Packed {
    let _cjbind_opaque_blob: VArray<UInt8, $5>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $5>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Packed>()
        if (size != 5) {
            throw Exception("Size of Packed is not 5 but ${size} bytes")
        }
        let align = alignOf<Packed>()
        if (align != 1) {
            throw Exception("Alignment of Packed is not 1 but ${align} bytes")
        }
}
