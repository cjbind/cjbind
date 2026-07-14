package cjbind_ffi

@C
public struct strct_strct {
    public let field: Int32
    public func clone(): strct_strct {
        return this
    }
    public func toString(): String {
        var output = "strct_strct {"
        output += " field: "
        output += this.field.toString()
        output += " }"
        return output
    }
    public init(field: Int32) {
        this.field = field
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<strct_strct>()
        if (size != 4) {
            throw Exception("Size of strct_strct is not 4 but ${size} bytes")
        }
        let align = alignOf<strct_strct>()
        if (align != 4) {
            throw Exception("Alignment of strct_strct is not 4 but ${align} bytes")
        }
}

public type typ_typ = VArray<strct_strct, $1>

foreign func function(a: CPointer<strct_strct>, b: CPointer<strct_strct>): Unit
