package cjbind_ffi

public type HasExternalPtr_Alias_Alias<T> = T

@C
public struct HasExternalPtr_HasExternalPtr {
    public let value: ExternalPtr_ExternalPtr
    public init(value: ExternalPtr_ExternalPtr) {
        this.value = value
    }
}

public type ConcreteExternalAlias_ConcreteExternalAlias = HasExternalPtr_HasExternalPtr

@C
public struct BlocklistedAliasArgumentHolder_BlocklistedAliasArgumentHolder {
    public let value: HasExternalPtr_HasExternalPtr
    public func clone(): BlocklistedAliasArgumentHolder_BlocklistedAliasArgumentHolder {
        return this
    }
    public func toString(): String {
        var output = "BlocklistedAliasArgumentHolder_BlocklistedAliasArgumentHolder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: HasExternalPtr_HasExternalPtr) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BlocklistedAliasArgumentHolder_BlocklistedAliasArgumentHolder>()
        if (size != 1) {
            throw Exception(
                "Size of BlocklistedAliasArgumentHolder_BlocklistedAliasArgumentHolder is not 1 but ${size} bytes")
        }
        let align = alignOf<BlocklistedAliasArgumentHolder_BlocklistedAliasArgumentHolder>()
        if (align != 1) {
            throw Exception(
                "Alignment of BlocklistedAliasArgumentHolder_BlocklistedAliasArgumentHolder is not 1 but ${align} bytes")
        }
}
