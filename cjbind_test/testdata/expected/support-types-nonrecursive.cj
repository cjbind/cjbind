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

// ABI-only opaque pointer for a C variadic callback. The generic arguments document the source signature; this alias is not callable from Cangjie.
public type __CjbindVariadicFunction1<R, A0> = CPointer<Unit>

@C
public struct SupportHolder {
    public var value: __CjbindComplexFloat64
    public var callback: __CjbindVariadicFunction1<Unit, Int32>
    public init(value: __CjbindComplexFloat64, callback: __CjbindVariadicFunction1<Unit, Int32>) {
        this.value = value
        this.callback = callback
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SupportHolder>()
        if (size != 24) {
            throw Exception("Size of SupportHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<SupportHolder>()
        if (align != 8) {
            throw Exception("Alignment of SupportHolder is not 8 but ${align} bytes")
        }
}
