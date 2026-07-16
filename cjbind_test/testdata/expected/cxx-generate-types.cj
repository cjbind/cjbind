package cjbind_ffi

@C
public struct SelectedType {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectedType>()
        if (size != 4) {
            throw Exception("Size of SelectedType is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectedType>()
        if (align != 4) {
            throw Exception("Alignment of SelectedType is not 4 but ${align} bytes")
        }
}
