package cjbind_ffi

@C
public struct dm_deps_dm_deps {
    public let count: UInt32
    public let filler: UInt32
    public let device: CPointer<UInt64>
    public init(count: UInt32, filler: UInt32, device: CPointer<UInt64>) {
        this.count = count
        this.filler = filler
        this.device = device
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<dm_deps_dm_deps>()
        if (size != 8) {
            throw Exception("Size of dm_deps_dm_deps is not 8 but ${size} bytes")
        }
        let align = alignOf<dm_deps_dm_deps>()
        if (align != 8) {
            throw Exception("Alignment of dm_deps_dm_deps is not 8 but ${align} bytes")
        }
}
