package cjbind_ffi

@C
public struct TemplateBaseRecoveryHolder {
    public let value: RecoveredDerived_open0_int_close0
    private init(value: RecoveredDerived_open0_int_close0) {
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

@C
public struct RecoveredDerived_open0_int_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $2>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecoveredDerived_open0_int_close0>()
        if (size != 8) {
            throw Exception("Size of RecoveredDerived_open0_int_close0 is not 8 but ${size} bytes")
        }
        let align = alignOf<RecoveredDerived_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of RecoveredDerived_open0_int_close0 is not 4 but ${align} bytes")
        }
}
