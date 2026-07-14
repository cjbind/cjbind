package cjbind_ffi

@C
public struct PolicyOptionFixture_PolicyOptionFixture {
    public let value: Int32
    public operator func ==(right: PolicyOptionFixture_PolicyOptionFixture): Bool {
        if (this.value != right.value) {
            return false
        }
        return true
    }
    public operator func !=(right: PolicyOptionFixture_PolicyOptionFixture): Bool {
        return !(this == right)
    }
    public static func default(): PolicyOptionFixture_PolicyOptionFixture {
        return unsafe { zeroValue<PolicyOptionFixture_PolicyOptionFixture>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this.value.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: PolicyOptionFixture_PolicyOptionFixture): ?Ordering {
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
    public operator func <(right: PolicyOptionFixture_PolicyOptionFixture): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: PolicyOptionFixture_PolicyOptionFixture): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: PolicyOptionFixture_PolicyOptionFixture): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: PolicyOptionFixture_PolicyOptionFixture): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PolicyOptionFixture_PolicyOptionFixture>()
        if (size != 4) {
            throw Exception("Size of PolicyOptionFixture_PolicyOptionFixture is not 4 but ${size} bytes")
        }
        let align = alignOf<PolicyOptionFixture_PolicyOptionFixture>()
        if (align != 4) {
            throw Exception("Alignment of PolicyOptionFixture_PolicyOptionFixture is not 4 but ${align} bytes")
        }
}
