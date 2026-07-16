package cjbind_ffi

// ABI storage for C _Float16 / __fp16 values. The value property is a local bit view; Cangjie Float16 is still not a CType.
@C
public struct __CjbindFloat16 {
    public var bits: UInt16

    public init(bits: UInt16) {
        this.bits = bits
    }

    public init(value: Float16) {
        this.bits = value.toBits()
    }

    public mut prop value: Float16 {
        get() {
            return Float16.fromBits(this.bits)
        }
        set(value) {
            this.bits = value.toBits()
        }
    }
}

@C
public struct Test__Float16 {
    public var f: __CjbindFloat16
    public init(f: __CjbindFloat16) {
        this.f = f
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Test__Float16>()
        if (size != 2) {
            throw Exception("Size of Test__Float16 is not 2 but ${size} bytes")
        }
        let align = alignOf<Test__Float16>()
        if (align != 2) {
            throw Exception("Alignment of Test__Float16 is not 2 but ${align} bytes")
        }
}

@C
public struct Test__Float16Ref {
    public var f: CPointer<__CjbindFloat16>
    public init(f: CPointer<__CjbindFloat16>) {
        this.f = f
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Test__Float16Ref>()
        if (size != 8) {
            throw Exception("Size of Test__Float16Ref is not 8 but ${size} bytes")
        }
        let align = alignOf<Test__Float16Ref>()
        if (align != 8) {
            throw Exception("Alignment of Test__Float16Ref is not 8 but ${align} bytes")
        }
}
