package cjbind_ffi

@C
public struct TestDouble_TestDouble {
    public let mMember: VArray<UInt64, $2>
    public func clone(): TestDouble_TestDouble {
        return this
    }
    public func toString(): String {
        var output = "TestDouble_TestDouble {"
        output += " mMember: "
        output += "<opaque>"
        output += " }"
        return output
    }
    public init(mMember: VArray<UInt64, $2>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestDouble_TestDouble>()
        if (size != 16) {
            throw Exception("Size of TestDouble_TestDouble is not 16 but ${size} bytes")
        }
        let align = alignOf<TestDouble_TestDouble>()
        if (align != 8) {
            throw Exception("Alignment of TestDouble_TestDouble is not 8 but ${align} bytes")
        }
}

@C
public struct TestDoublePtr_TestDoublePtr {
    public let mMember: CPointer<VArray<UInt64, $2>>
    public func clone(): TestDoublePtr_TestDoublePtr {
        return this
    }
    public func toString(): String {
        var output = "TestDoublePtr_TestDoublePtr {"
        output += " mMember: "
        output += CPointer<Unit>(this.mMember).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(mMember: CPointer<VArray<UInt64, $2>>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestDoublePtr_TestDoublePtr>()
        if (size != 8) {
            throw Exception("Size of TestDoublePtr_TestDoublePtr is not 8 but ${size} bytes")
        }
        let align = alignOf<TestDoublePtr_TestDoublePtr>()
        if (align != 8) {
            throw Exception("Alignment of TestDoublePtr_TestDoublePtr is not 8 but ${align} bytes")
        }
}

@C
public struct TestFloat_TestFloat {
    public let mMember: VArray<UInt32, $2>
    public func clone(): TestFloat_TestFloat {
        return this
    }
    public func toString(): String {
        var output = "TestFloat_TestFloat {"
        output += " mMember: "
        output += "<opaque>"
        output += " }"
        return output
    }
    public init(mMember: VArray<UInt32, $2>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestFloat_TestFloat>()
        if (size != 8) {
            throw Exception("Size of TestFloat_TestFloat is not 8 but ${size} bytes")
        }
        let align = alignOf<TestFloat_TestFloat>()
        if (align != 4) {
            throw Exception("Alignment of TestFloat_TestFloat is not 4 but ${align} bytes")
        }
}

@C
public struct TestFloatPtr_TestFloatPtr {
    public let mMember: CPointer<VArray<UInt32, $2>>
    public func clone(): TestFloatPtr_TestFloatPtr {
        return this
    }
    public func toString(): String {
        var output = "TestFloatPtr_TestFloatPtr {"
        output += " mMember: "
        output += CPointer<Unit>(this.mMember).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(mMember: CPointer<VArray<UInt32, $2>>) {
        this.mMember = mMember
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TestFloatPtr_TestFloatPtr>()
        if (size != 8) {
            throw Exception("Size of TestFloatPtr_TestFloatPtr is not 8 but ${size} bytes")
        }
        let align = alignOf<TestFloatPtr_TestFloatPtr>()
        if (align != 8) {
            throw Exception("Alignment of TestFloatPtr_TestFloatPtr is not 8 but ${align} bytes")
        }
}
