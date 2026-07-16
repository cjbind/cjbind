package cjbind_ffi

@C
public struct PolicyOptionFixture {
    public var value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PolicyOptionFixture>()
        if (size != 4) {
            throw Exception("Size of PolicyOptionFixture is not 4 but ${size} bytes")
        }
        let align = alignOf<PolicyOptionFixture>()
        if (align != 4) {
            throw Exception("Alignment of PolicyOptionFixture is not 4 but ${align} bytes")
        }
}
