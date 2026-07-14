package cjbind_ffi

@C
public struct SelectedOuter_SelectedOuter {
    public let inner: SelectedInner_SelectedInner
    public init(inner: SelectedInner_SelectedInner) {
        this.inner = inner
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectedOuter_SelectedOuter>()
        if (size != 4) {
            throw Exception("Size of SelectedOuter_SelectedOuter is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectedOuter_SelectedOuter>()
        if (align != 4) {
            throw Exception("Alignment of SelectedOuter_SelectedOuter is not 4 but ${align} bytes")
        }
}
