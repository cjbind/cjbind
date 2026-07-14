package cjbind_ffi

@C
public struct ManualExternalHolder_ManualExternalHolder {
    public let external: ManualExternal_ManualExternal
    public let visible: Int32
    public func toString(): String {
        var output = "ManualExternalHolder_ManualExternalHolder {"
        output += " visible: "
        output += this.visible.toString()
        output += " }"
        return output
    }
    public operator func ==(right: ManualExternalHolder_ManualExternalHolder): Bool {
        if (this.external != right.external) {
            return false
        }
        if (this.visible != right.visible) {
            return false
        }
        return true
    }
    public operator func !=(right: ManualExternalHolder_ManualExternalHolder): Bool {
        return !(this == right)
    }
    public init(external: ManualExternal_ManualExternal, visible: Int32) {
        this.external = external
        this.visible = visible
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ManualExternalHolder_ManualExternalHolder>()
        if (size != 8) {
            throw Exception("Size of ManualExternalHolder_ManualExternalHolder is not 8 but ${size} bytes")
        }
        let align = alignOf<ManualExternalHolder_ManualExternalHolder>()
        if (align != 4) {
            throw Exception("Alignment of ManualExternalHolder_ManualExternalHolder is not 4 but ${align} bytes")
        }
}
