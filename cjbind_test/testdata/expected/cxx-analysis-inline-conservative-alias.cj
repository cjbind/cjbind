package cjbind_ffi

public type api_v1_Word_Word = Int32

public type api_Word_Word = Int64

@C
public struct UsesInlineAlias_UsesInlineAlias {
    public let value: api_v1_Word_Word
    public func clone(): UsesInlineAlias_UsesInlineAlias {
        return this
    }
    public func toString(): String {
        var output = "UsesInlineAlias_UsesInlineAlias {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: api_v1_Word_Word) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<UsesInlineAlias_UsesInlineAlias>()
        if (size != 4) {
            throw Exception("Size of UsesInlineAlias_UsesInlineAlias is not 4 but ${size} bytes")
        }
        let align = alignOf<UsesInlineAlias_UsesInlineAlias>()
        if (align != 4) {
            throw Exception("Alignment of UsesInlineAlias_UsesInlineAlias is not 4 but ${align} bytes")
        }
}
