package cjbind_ffi

@C
public struct a_a {
    public let b: Int32
    public func clone(): a_a {
        return this
    }
    public func toString(): String {
        var output = "a_a {"
        output += " b: "
        output += this.b.toString()
        output += " }"
        return output
    }
    public init(b: Int32) {
        this.b = b
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<a_a>()
        if (size != 4) {
            throw Exception("Size of a_a is not 4 but ${size} bytes")
        }
        let align = alignOf<a_a>()
        if (align != 4) {
            throw Exception("Alignment of a_a is not 4 but ${align} bytes")
        }
}

@C
public struct c_c {
    public let d: Int32
    public func clone(): c_c {
        return this
    }
    public func toString(): String {
        var output = "c_c {"
        output += " d: "
        output += this.d.toString()
        output += " }"
        return output
    }
    public init(d: Int32) {
        this.d = d
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<c_c>()
        if (size != 4) {
            throw Exception("Size of c_c is not 4 but ${size} bytes")
        }
        let align = alignOf<c_c>()
        if (align != 4) {
            throw Exception("Alignment of c_c is not 4 but ${align} bytes")
        }
}
