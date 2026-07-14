package cjbind_ffi

@C
public struct U4 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<U4>()
        if (size != 4) {
            throw Exception("Size of U4 is not 4 but ${size} bytes")
        }
        let align = alignOf<U4>()
        if (align != 4) {
            throw Exception("Alignment of U4 is not 4 but ${align} bytes")
        }
}

@C
public struct B {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<B>()
        if (size != 4) {
            throw Exception("Size of B is not 4 but ${size} bytes")
        }
        let align = alignOf<B>()
        if (align != 4) {
            throw Exception("Alignment of B is not 4 but ${align} bytes")
        }
}
