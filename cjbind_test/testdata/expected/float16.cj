package cjbind_ffi

@C
public struct Test__Float16_Test__Float16 {
    public let f: Float16
    public init(f: Float16) {
        this.f = f
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Test__Float16_Test__Float16>()
        if (size != 2) {
            throw Exception("Size of Test__Float16_Test__Float16 is not 2 but ${size} bytes")
        }
        let align = alignOf<Test__Float16_Test__Float16>()
        if (align != 2) {
            throw Exception("Alignment of Test__Float16_Test__Float16 is not 2 but ${align} bytes")
        }
}

@C
public struct Test__Float16Ref_Test__Float16Ref {
    public let f: CPointer<Float16>
    public init(f: CPointer<Float16>) {
        this.f = f
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Test__Float16Ref_Test__Float16Ref>()
        if (size != 8) {
            throw Exception("Size of Test__Float16Ref_Test__Float16Ref is not 8 but ${size} bytes")
        }
        let align = alignOf<Test__Float16Ref_Test__Float16Ref>()
        if (align != 8) {
            throw Exception("Alignment of Test__Float16Ref_Test__Float16Ref is not 8 but ${align} bytes")
        }
}