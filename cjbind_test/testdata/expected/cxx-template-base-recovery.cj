package cjbind_ffi

@C
public struct RecoveredDerived_RecoveredDerived {
    public let _base: RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0
    public let derivedValue: Int16
    public func clone(): RecoveredDerived_RecoveredDerived {
        return this
    }
    public func toString(): String {
        var output = "RecoveredDerived_RecoveredDerived {"
        output += " _base: "
        output += this._base.toString()
        output += ", derivedValue: "
        output += this.derivedValue.toString()
        output += " }"
        return output
    }
    public init(_base: RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0, derivedValue: Int16) {
        this._base = _base
        this.derivedValue = derivedValue
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecoveredDerived_RecoveredDerived>()
        if (size != 8) {
            throw Exception("Size of RecoveredDerived_RecoveredDerived is not 8 but ${size} bytes")
        }
        let align = alignOf<RecoveredDerived_RecoveredDerived>()
        if (align != 4) {
            throw Exception("Alignment of RecoveredDerived_RecoveredDerived is not 4 but ${align} bytes")
        }
}

@C
public struct RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0 {
    public let baseValue: Int32
    public func clone(): RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0 {"
        output += " baseValue: "
        output += this.baseValue.toString()
        output += " }"
        return output
    }
    public init(baseValue: Int32) {
        this.baseValue = baseValue
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of RecoveredBase_open0_int_close0_RecoveredBase_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateBaseRecoveryHolder_TemplateBaseRecoveryHolder {
    public let value: RecoveredDerived_RecoveredDerived
    public func clone(): TemplateBaseRecoveryHolder_TemplateBaseRecoveryHolder {
        return this
    }
    public func toString(): String {
        var output = "TemplateBaseRecoveryHolder_TemplateBaseRecoveryHolder {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: RecoveredDerived_RecoveredDerived) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateBaseRecoveryHolder_TemplateBaseRecoveryHolder>()
        if (size != 8) {
            throw Exception("Size of TemplateBaseRecoveryHolder_TemplateBaseRecoveryHolder is not 8 but ${size} bytes")
        }
        let align = alignOf<TemplateBaseRecoveryHolder_TemplateBaseRecoveryHolder>()
        if (align != 4) {
            throw Exception(
                "Alignment of TemplateBaseRecoveryHolder_TemplateBaseRecoveryHolder is not 4 but ${align} bytes")
        }
}
