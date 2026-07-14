package cjbind_ffi

@C
public struct ExternalCapabilitiesHolder_ExternalCapabilitiesHolder {
    public let external: ExternalCapabilities_ExternalCapabilities
    public let visible: Int32
    public func clone(): ExternalCapabilitiesHolder_ExternalCapabilitiesHolder {
        return this
    }
    public func toString(): String {
        var output = "ExternalCapabilitiesHolder_ExternalCapabilitiesHolder {"
        output += " external: "
        output += this.external.toString()
        output += ", visible: "
        output += this.visible.toString()
        output += " }"
        return output
    }
    public operator func ==(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): Bool {
        if (this.external != right.external) {
            return false
        }
        if (this.visible != right.visible) {
            return false
        }
        return true
    }
    public operator func !=(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): Bool {
        return !(this == right)
    }
    public static func default(): ExternalCapabilitiesHolder_ExternalCapabilitiesHolder {
        return unsafe { zeroValue<ExternalCapabilitiesHolder_ExternalCapabilitiesHolder>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this.external.hashCode()
        hash = ((hash << 5) | (hash >> 59)) ^ this.visible.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): ?Ordering {
        if (this.external < right.external) {
            return Some(Ordering.LT)
        }
        if (this.external > right.external) {
            return Some(Ordering.GT)
        }
        if (this.external != right.external) {
            return None
        }
        if (this.visible < right.visible) {
            return Some(Ordering.LT)
        }
        if (this.visible > right.visible) {
            return Some(Ordering.GT)
        }
        if (this.visible != right.visible) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: ExternalCapabilitiesHolder_ExternalCapabilitiesHolder): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(external: ExternalCapabilities_ExternalCapabilities, visible: Int32) {
        this.external = external
        this.visible = visible
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ExternalCapabilitiesHolder_ExternalCapabilitiesHolder>()
        if (size != 16) {
            throw Exception("Size of ExternalCapabilitiesHolder_ExternalCapabilitiesHolder is not 16 but ${size} bytes")
        }
        let align = alignOf<ExternalCapabilitiesHolder_ExternalCapabilitiesHolder>()
        if (align != 4) {
            throw Exception(
                "Alignment of ExternalCapabilitiesHolder_ExternalCapabilitiesHolder is not 4 but ${align} bytes")
        }
}
