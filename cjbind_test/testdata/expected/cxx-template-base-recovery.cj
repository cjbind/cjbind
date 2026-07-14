package cjbind_ffi

@C
public struct TemplateBaseRecoveryHolder {
    public let value: VArray<UInt32, $2>
    public init(value: VArray<UInt32, $2>) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateBaseRecoveryHolder>()
        if (size != 8) {
            throw Exception("Size of TemplateBaseRecoveryHolder is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateBaseRecoveryHolder>()
        if (align != 4) {
            throw Exception("Alignment of TemplateBaseRecoveryHolder is not 4 but ${align} bytes")
        }
}
