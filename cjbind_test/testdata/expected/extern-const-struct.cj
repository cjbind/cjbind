package cjbind_ffi

@C
public struct nsFoo_nsFoo {
    public let details: VArray<Float32, $400>
    public func clone(): nsFoo_nsFoo {
        return this
    }
    public func toString(): String {
        var output = "nsFoo_nsFoo {"
        output += " details: "
        output += "["
        for (__cjbindDebugIndex0 in 0..400) {
            if (__cjbindDebugIndex0 != 0) {
                output += ", "
            }
            output += this.details[__cjbindDebugIndex0].toString()
        }
        output += "]"
        output += " }"
        return output
    }
    public init(details: VArray<Float32, $400>) {
        this.details = details
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<nsFoo_nsFoo>()
        if (size != 1600) {
            throw Exception("Size of nsFoo_nsFoo is not 1600 but ${size} bytes")
        }
        let align = alignOf<nsFoo_nsFoo>()
        if (align != 4) {
            throw Exception("Alignment of nsFoo_nsFoo is not 4 but ${align} bytes")
        }
}
