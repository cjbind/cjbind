package cjbind_ffi

@C
public struct SelectedType_SelectedType {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SelectedType_SelectedType>()
        if (size != 4) {
            throw Exception("Size of SelectedType_SelectedType is not 4 but ${size} bytes")
        }
        let align = alignOf<SelectedType_SelectedType>()
        if (align != 4) {
            throw Exception("Alignment of SelectedType_SelectedType is not 4 but ${align} bytes")
        }
}
