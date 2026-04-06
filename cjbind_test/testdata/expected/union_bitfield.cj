package cjbind_ffi

@C
public struct U4_U4 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<U4_U4>()
        if (size != 4) {
            throw Exception("Size of U4_U4 is not 4 but ${size} bytes")
        }
        let align = alignOf<U4_U4>()
        if (align != 4) {
            throw Exception("Alignment of U4_U4 is not 4 but ${align} bytes")
        }
}

@C
public struct B_B {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<B_B>()
        if (size != 4) {
            throw Exception("Size of B_B is not 4 but ${size} bytes")
        }
        let align = alignOf<B_B>()
        if (align != 4) {
            throw Exception("Alignment of B_B is not 4 but ${align} bytes")
        }
}
