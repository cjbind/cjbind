package cjbind_ffi

@C
public struct SelectedOuter {
    public let inner: SelectedInner
    public init(inner: SelectedInner) {
        this.inner = inner
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectedOuter>()
        if (size != 4) {
            throw Exception("Size of SelectedOuter is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectedOuter>()
        if (align != 4) {
            throw Exception("Alignment of SelectedOuter is not 4 but ${align} bytes")
        }
}
