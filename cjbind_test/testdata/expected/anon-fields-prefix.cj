package cjbind_ffi

@C
public struct color__cjbind_ty_1 {
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public init(r: UInt8, g: UInt8, b: UInt8) {
        this.r = r
        this.g = g
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<color__cjbind_ty_1>()
        if (size != 3) {
            throw Exception("Size of color__cjbind_ty_1 is not 3 but ${size} bytes")
        }
        let align = alignOf<color__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of color__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct color__cjbind_ty_2 {
    public var y: UInt8
    public var u: UInt8
    public var v: UInt8
    public init(y: UInt8, u: UInt8, v: UInt8) {
        this.y = y
        this.u = u
        this.v = v
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<color__cjbind_ty_2>()
        if (size != 3) {
            throw Exception("Size of color__cjbind_ty_2 is not 3 but ${size} bytes")
        }
        let align = alignOf<color__cjbind_ty_2>()
        if (align != 1) {
            throw Exception("Alignment of color__cjbind_ty_2 is not 1 but ${align} bytes")
        }
}

@C
public struct color {
    var _storage: VArray<UInt8, $3> = unsafe { zeroValue<VArray<UInt8, $3>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<color>()
        if (size != 3) {
            throw Exception("Size of color is not 3 but ${size} bytes")
        }
        let align = alignOf<color>()
        if (align != 1) {
            throw Exception("Alignment of color is not 1 but ${align} bytes")
        }
}
