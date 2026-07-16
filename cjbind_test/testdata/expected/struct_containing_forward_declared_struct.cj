package cjbind_ffi

@C
public struct a {
    public var val_a: CPointer<b>
    public init(val_a: CPointer<b>) {
        this.val_a = val_a
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<a>()
        if (size != 8) {
            throw Exception("Size of a is not 8 but ${size} bytes")
        }
        let align = alignOf<a>()
        if (align != 8) {
            throw Exception("Alignment of a is not 8 but ${align} bytes")
        }
}

@C
public struct b {
    public var val_b: Int32
    public init(val_b: Int32) {
        this.val_b = val_b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<b>()
        if (size != 4) {
            throw Exception("Size of b is not 4 but ${size} bytes")
        }
        let align = alignOf<b>()
        if (align != 4) {
            throw Exception("Alignment of b is not 4 but ${align} bytes")
        }
}
