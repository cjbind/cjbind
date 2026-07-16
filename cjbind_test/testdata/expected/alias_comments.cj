package cjbind_ffi

// This is Struct
@C
public struct Struct {
    // This is field
    public var field: Int32
    public init(field: Int32) {
        this.field = field
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Struct>()
        if (size != 4) {
            throw Exception("Size of Struct is not 4 but ${size} bytes")
        }
        let align = alignOf<Struct>()
        if (align != 4) {
            throw Exception("Alignment of Struct is not 4 but ${align} bytes")
        }
}

// This is AliasToStruct
public type AliasToStruct = Struct

// This is AliasToInt
public type AliasToInt = Int32

// This is AliasToAliasToInt
public type AliasToAliasToInt = AliasToInt
