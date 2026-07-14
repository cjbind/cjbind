package cjbind_ffi

@C
public struct nsFoo {
    public let details: VArray<Float32, $400>
    public init(details: VArray<Float32, $400>) {
        this.details = details
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<nsFoo>()
        if (size != 1600) {
            throw Exception("Size of nsFoo is not 1600 but ${size} bytes")
        }
        let align = alignOf<nsFoo>()
        if (align != 4) {
            throw Exception("Alignment of nsFoo is not 4 but ${align} bytes")
        }
}
