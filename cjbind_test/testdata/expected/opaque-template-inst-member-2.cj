package cjbind_ffi

@C
public struct OpaqueTemplate {
    let _cjbind_empty: UInt8
    private init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@C
public struct ContainsOpaqueTemplate {
    public let mBlah: UInt32
    public var mBaz: Int32
    private init(mBlah: UInt32, mBaz: Int32) {
        this.mBlah = mBlah
        this.mBaz = mBaz
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ContainsOpaqueTemplate>()
        if (size != 8) {
            throw Exception("Size of ContainsOpaqueTemplate is not 8 but ${size} bytes")
        }
        let align = alignOf<ContainsOpaqueTemplate>()
        if (align != 4) {
            throw Exception("Alignment of ContainsOpaqueTemplate is not 4 but ${align} bytes")
        }
}

@C
public struct InheritsOpaqueTemplate {
    public let _base: UInt8
    public var wow: CPointer<UInt8>
    private init(_base: UInt8, wow: CPointer<UInt8>) {
        this._base = _base
        this.wow = wow
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<InheritsOpaqueTemplate>()
        if (size != 16) {
            throw Exception("Size of InheritsOpaqueTemplate is not 16 but ${size} bytes")
        }
        let align = alignOf<InheritsOpaqueTemplate>()
        if (align != 8) {
            throw Exception("Alignment of InheritsOpaqueTemplate is not 8 but ${align} bytes")
        }
}
