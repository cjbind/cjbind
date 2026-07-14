package cjbind_ffi

@C
public struct EmptyUnion_EmptyUnion {
    var _storage: UInt8 = unsafe { zeroValue<UInt8>() }
    public init() {}
    public func clone(): EmptyUnion_EmptyUnion {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<EmptyUnion_EmptyUnion>()
        if (size != 1) {
            throw Exception("Size of EmptyUnion_EmptyUnion is not 1 but ${size} bytes")
        }
        let align = alignOf<EmptyUnion_EmptyUnion>()
        if (align != 1) {
            throw Exception("Alignment of EmptyUnion_EmptyUnion is not 1 but ${align} bytes")
        }
}
