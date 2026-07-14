package cjbind_ffi

public type api_v1_Word = Int32

public type api_Word = Int64

@C
public struct UsesInlineAlias {
    public let value: api_v1_Word
    public init(value: api_v1_Word) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesInlineAlias>()
        if (size != 4) {
            throw Exception("Size of UsesInlineAlias is not 4 but ${size} bytes")
        }
        let align = alignOf<UsesInlineAlias>()
        if (align != 4) {
            throw Exception("Alignment of UsesInlineAlias is not 4 but ${align} bytes")
        }
}
