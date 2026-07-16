package cjbind_ffi

public type HasExternalPtr_Alias<T> = T

public type ConcreteExternalAlias = UInt8

@C
public struct BlocklistedAliasArgumentHolder {
    public let value: ConcreteExternalAlias
    private init(value: ConcreteExternalAlias) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BlocklistedAliasArgumentHolder>()
        if (size != 1) {
            throw Exception("Size of BlocklistedAliasArgumentHolder is not 1 but ${size} bytes")
        }
        let align = alignOf<BlocklistedAliasArgumentHolder>()
        if (align != 1) {
            throw Exception("Alignment of BlocklistedAliasArgumentHolder is not 1 but ${align} bytes")
        }
}
