package cjbind_ffi

@C
public struct EmptyUnion {
    var _storage: UInt8 = unsafe { zeroValue<UInt8>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<EmptyUnion>()
        if (size != 1) {
            throw Exception("Size of EmptyUnion is not 1 but ${size} bytes")
        }
        let align = alignOf<EmptyUnion>()
        if (align != 1) {
            throw Exception("Alignment of EmptyUnion is not 1 but ${align} bytes")
        }
}
