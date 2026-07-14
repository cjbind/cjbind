package cjbind_ffi

@C
public struct strct {
    public let field: Int32
    public init(field: Int32) {
        this.field = field
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<strct>()
        if (size != 4) {
            throw Exception("Size of strct is not 4 but ${size} bytes")
        }
        let align = alignOf<strct>()
        if (align != 4) {
            throw Exception("Alignment of strct is not 4 but ${align} bytes")
        }
}

public type typ = VArray<strct, $1>

foreign func function(a: CPointer<strct>, b: CPointer<strct>): Unit
