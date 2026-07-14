package cjbind_ffi

@C
public struct TestDouble {
    public let mMember: VArray<UInt64, $2>
    public init(mMember: VArray<UInt64, $2>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestDouble>()
        if (size != 16) {
            throw Exception("Size of TestDouble is not 16 but ${size} bytes")
        }
        let align = alignOf<TestDouble>()
        if (align != 8) {
            throw Exception("Alignment of TestDouble is not 8 but ${align} bytes")
        }
}

@C
public struct TestDoublePtr {
    public let mMember: CPointer<VArray<UInt64, $2>>
    public init(mMember: CPointer<VArray<UInt64, $2>>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestDoublePtr>()
        if (size != 8) {
            throw Exception("Size of TestDoublePtr is not 8 but ${size} bytes")
        }
        let align = alignOf<TestDoublePtr>()
        if (align != 8) {
            throw Exception("Alignment of TestDoublePtr is not 8 but ${align} bytes")
        }
}

@C
public struct TestFloat {
    public let mMember: VArray<UInt32, $2>
    public init(mMember: VArray<UInt32, $2>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestFloat>()
        if (size != 8) {
            throw Exception("Size of TestFloat is not 8 but ${size} bytes")
        }
        let align = alignOf<TestFloat>()
        if (align != 4) {
            throw Exception("Alignment of TestFloat is not 4 but ${align} bytes")
        }
}

@C
public struct TestFloatPtr {
    public let mMember: CPointer<VArray<UInt32, $2>>
    public init(mMember: CPointer<VArray<UInt32, $2>>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestFloatPtr>()
        if (size != 8) {
            throw Exception("Size of TestFloatPtr is not 8 but ${size} bytes")
        }
        let align = alignOf<TestFloatPtr>()
        if (align != 8) {
            throw Exception("Alignment of TestFloatPtr is not 8 but ${align} bytes")
        }
}
