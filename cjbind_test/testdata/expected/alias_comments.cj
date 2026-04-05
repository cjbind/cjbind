package cjbind_ffi

// This is Struct
@C
public struct Struct_Struct {
    // This is field
    public let field: Int32
    public init(field: Int32) {
        this.field = field
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Struct_Struct>()
        if (size != 4) {
            throw Exception("Size of Struct_Struct is not 4 but ${size} bytes")
        }
        let align = alignOf<Struct_Struct>()
        if (align != 4) {
            throw Exception("Alignment of Struct_Struct is not 4 but ${align} bytes")
        }
}

// This is AliasToStruct
public type AliasToStruct_AliasToStruct = Struct_Struct

// This is AliasToInt
public type AliasToInt_AliasToInt = Int32

// This is AliasToAliasToInt
public type AliasToAliasToInt_AliasToAliasToInt = AliasToInt_AliasToInt
