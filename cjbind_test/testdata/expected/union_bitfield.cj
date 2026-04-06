package cjbind_ffi

@C
public struct U4_U4 {
    var _storage: VArray<UInt8, $4> = unsafe { zeroValue<VArray<UInt8, $4>>() }
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
        if (align != 1) {
            throw Exception("Alignment of U4_U4 is not 1 but ${align} bytes")
        }
}

@C
public struct B_B {
    var _storage: VArray<UInt8, $4> = unsafe { zeroValue<VArray<UInt8, $4>>() }
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
        if (align != 1) {
            throw Exception("Alignment of B_B is not 1 but ${align} bytes")
        }
}
