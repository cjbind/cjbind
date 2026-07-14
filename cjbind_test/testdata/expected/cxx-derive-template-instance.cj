package cjbind_ffi

@C
public struct DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0 {
    public let value: Int32
    public func clone(): DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public operator func ==(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): Bool {
        if (this.value != right.value) {
            return false
        }
        return true
    }
    public operator func !=(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): Bool {
        return !(this == right)
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this.value.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): ?Ordering {
        if (this.value < right.value) {
            return Some(Ordering.LT)
        }
        if (this.value > right.value) {
            return Some(Ordering.GT)
        }
        if (this.value != right.value) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0 {
    let _cjbind_opaque_blob: VArray<UInt32, $3>
    public func clone(): ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public operator func ==(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): Bool {
        for (__cjbindEqIndex0 in 0..3) {
            if (this._cjbind_opaque_blob[__cjbindEqIndex0] != right._cjbind_opaque_blob[__cjbindEqIndex0]) {
                return false
            }
        }
        return true
    }
    public operator func !=(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): Bool {
        return !(this == right)
    }
    public static func default(): ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0 {
        return unsafe { zeroValue<ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        for (__cjbindHashIndex0 in 0..3) {
            hash = ((hash << 5) | (hash >> 59)) ^ this._cjbind_opaque_blob[__cjbindHashIndex0].hashCode()
        }
        return hash
    }
    public func __cjbindPartialCompare(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): ?Ordering {
        for (__cjbindOrdIndex0 in 0..3) {
            if (this._cjbind_opaque_blob[__cjbindOrdIndex0] < right._cjbind_opaque_blob[__cjbindOrdIndex0]) {
                return Some(Ordering.LT)
            }
            if (this._cjbind_opaque_blob[__cjbindOrdIndex0] > right._cjbind_opaque_blob[__cjbindOrdIndex0]) {
                return Some(Ordering.GT)
            }
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt32, $3>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0>()
        if (size != 12) {
            throw Exception(
                "Size of ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0 is not 12 but ${size} bytes")
        }
        let align = alignOf<ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct TemplateDerivesHolder_TemplateDerivesHolder {
    public let visible: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0
    public let opaque: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0
    public func clone(): TemplateDerivesHolder_TemplateDerivesHolder {
        return this
    }
    public func toString(): String {
        var output = "TemplateDerivesHolder_TemplateDerivesHolder {"
        output += " visible: "
        output += this.visible.toString()
        output += ", opaque: "
        output += this.opaque.toString()
        output += " }"
        return output
    }
    public operator func ==(right: TemplateDerivesHolder_TemplateDerivesHolder): Bool {
        if (this.visible != right.visible) {
            return false
        }
        if (this.opaque != right.opaque) {
            return false
        }
        return true
    }
    public operator func !=(right: TemplateDerivesHolder_TemplateDerivesHolder): Bool {
        return !(this == right)
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this.visible.hashCode()
        hash = ((hash << 5) | (hash >> 59)) ^ this.opaque.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: TemplateDerivesHolder_TemplateDerivesHolder): ?Ordering {
        match (this.visible.__cjbindPartialCompare(right.visible)) {
            case Some(Ordering.LT) => return Some(Ordering.LT)
            case Some(Ordering.GT) => return Some(Ordering.GT)
            case None => return None
            case _ => ()
        }
        match (this.opaque.__cjbindPartialCompare(right.opaque)) {
            case Some(Ordering.LT) => return Some(Ordering.LT)
            case Some(Ordering.GT) => return Some(Ordering.GT)
            case None => return None
            case _ => ()
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: TemplateDerivesHolder_TemplateDerivesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: TemplateDerivesHolder_TemplateDerivesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: TemplateDerivesHolder_TemplateDerivesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: TemplateDerivesHolder_TemplateDerivesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: TemplateDerivesHolder_TemplateDerivesHolder): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(visible: DerivedTemplate_open0_int_close0_DerivedTemplate_open0_int_close0,
        opaque: ConflictTemplate_open0_int_close0_ConflictTemplate_open0_int_close0) {
        this.visible = visible
        this.opaque = opaque
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TemplateDerivesHolder_TemplateDerivesHolder>()
        if (size != 16) {
            throw Exception("Size of TemplateDerivesHolder_TemplateDerivesHolder is not 16 but ${size} bytes")
        }
        let align = alignOf<TemplateDerivesHolder_TemplateDerivesHolder>()
        if (align != 4) {
            throw Exception("Alignment of TemplateDerivesHolder_TemplateDerivesHolder is not 4 but ${align} bytes")
        }
}
