package cjbind_ffi

@C
public struct a_a {
    public let val_a: CPointer<b_b>
    public init(val_a: CPointer<b_b>) {
        this.val_a = val_a
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<a_a>()
        if (size != 8) {
            throw Exception("Size of a_a is not 8 but ${size} bytes")
        }
        let align = alignOf<a_a>()
        if (align != 8) {
            throw Exception("Alignment of a_a is not 8 but ${align} bytes")
        }
}

@C
public struct b_b {
    public let val_b: Int32
    public init(val_b: Int32) {
        this.val_b = val_b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<b_b>()
        if (size != 4) {
            throw Exception("Size of b_b is not 4 but ${size} bytes")
        }
        let align = alignOf<b_b>()
        if (align != 4) {
            throw Exception("Alignment of b_b is not 4 but ${align} bytes")
        }
}
