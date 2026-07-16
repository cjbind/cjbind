package cjbind_ffi

@C
public struct a {
    public var b: Int32
    public init(b: Int32) {
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<a>()
        if (size != 4) {
            throw Exception("Size of a is not 4 but ${size} bytes")
        }
        let align = alignOf<a>()
        if (align != 4) {
            throw Exception("Alignment of a is not 4 but ${align} bytes")
        }
}

@C
public struct c {
    public var d: Int32
    public init(d: Int32) {
        this.d = d
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<c>()
        if (size != 4) {
            throw Exception("Size of c is not 4 but ${size} bytes")
        }
        let align = alignOf<c>()
        if (align != 4) {
            throw Exception("Alignment of c is not 4 but ${align} bytes")
        }
}
