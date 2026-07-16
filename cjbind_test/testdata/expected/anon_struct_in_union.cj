package cjbind_ffi

@C
public struct s__cjbind_ty_1_inner {
    public var b: Int32
    public init(b: Int32) {
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<s__cjbind_ty_1_inner>()
        if (size != 4) {
            throw Exception("Size of s__cjbind_ty_1_inner is not 4 but ${size} bytes")
        }
        let align = alignOf<s__cjbind_ty_1_inner>()
        if (align != 4) {
            throw Exception("Alignment of s__cjbind_ty_1_inner is not 4 but ${align} bytes")
        }
}

@C
public struct s__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<s__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of s__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<s__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of s__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct s {
    public let u: s__cjbind_ty_1
    public init(u: s__cjbind_ty_1) {
        this.u = u
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<s>()
        if (size != 4) {
            throw Exception("Size of s is not 4 but ${size} bytes")
        }
        let align = alignOf<s>()
        if (align != 4) {
            throw Exception("Alignment of s is not 4 but ${align} bytes")
        }
}
