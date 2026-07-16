package cjbind_ffi

// ABI-only memory carriers for C complex objects. Direct complex parameters and return values are intentionally not generated.
@C
public struct __CjbindComplexFloat16 {
    public var reBits: UInt16
    public var imBits: UInt16

    public init(reBits: UInt16, imBits: UInt16) {
        this.reBits = reBits
        this.imBits = imBits
    }

    public init(real: Float16, imaginary: Float16) {
        this.reBits = real.toBits()
        this.imBits = imaginary.toBits()
    }

    public mut prop real: Float16 {
        get() {
            return Float16.fromBits(this.reBits)
        }
        set(value) {
            this.reBits = value.toBits()
        }
    }

    public mut prop imaginary: Float16 {
        get() {
            return Float16.fromBits(this.imBits)
        }
        set(value) {
            this.imBits = value.toBits()
        }
    }
}

@C
public struct __CjbindComplexFloat32 {
    public var re: Float32
    public var im: Float32

    public init(re: Float32, im: Float32) {
        this.re = re
        this.im = im
    }

    public mut prop real: Float32 {
        get() {
            return this.re
        }
        set(value) {
            this.re = value
        }
    }

    public mut prop imaginary: Float32 {
        get() {
            return this.im
        }
        set(value) {
            this.im = value
        }
    }
}

@C
public struct __CjbindComplexFloat64 {
    public var re: Float64
    public var im: Float64

    public init(re: Float64, im: Float64) {
        this.re = re
        this.im = im
    }

    public mut prop real: Float64 {
        get() {
            return this.re
        }
        set(value) {
            this.re = value
        }
    }

    public mut prop imaginary: Float64 {
        get() {
            return this.im
        }
        set(value) {
            this.im = value
        }
    }
}

@C
public struct TestDouble {
    public var mMember: __CjbindComplexFloat64
    public init(mMember: __CjbindComplexFloat64) {
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
    public var mMember: CPointer<__CjbindComplexFloat64>
    public init(mMember: CPointer<__CjbindComplexFloat64>) {
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
    public var mMember: __CjbindComplexFloat32
    public init(mMember: __CjbindComplexFloat32) {
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
    public var mMember: CPointer<__CjbindComplexFloat32>
    public init(mMember: CPointer<__CjbindComplexFloat32>) {
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
