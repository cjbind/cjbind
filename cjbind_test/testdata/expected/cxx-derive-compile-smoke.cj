package cjbind_ffi

@C
public struct DeriveCompileSmoke_DeriveCompileSmoke {
    public let first: Int32
    public let second: Int32
    public func clone(): DeriveCompileSmoke_DeriveCompileSmoke {
        return this
    }
    public func toString(): String {
        var output = "DeriveCompileSmoke_DeriveCompileSmoke {"
        output += " first: "
        output += this.first.toString()
        output += ", second: "
        output += this.second.toString()
        output += " }"
        return output
    }
    public operator func ==(right: DeriveCompileSmoke_DeriveCompileSmoke): Bool {
        if (this.first != right.first) {
            return false
        }
        if (this.second != right.second) {
            return false
        }
        return true
    }
    public operator func !=(right: DeriveCompileSmoke_DeriveCompileSmoke): Bool {
        return !(this == right)
    }
    public static func default(): DeriveCompileSmoke_DeriveCompileSmoke {
        return unsafe { zeroValue<DeriveCompileSmoke_DeriveCompileSmoke>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ this.first.hashCode()
        hash = ((hash << 5) | (hash >> 59)) ^ this.second.hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: DeriveCompileSmoke_DeriveCompileSmoke): ?Ordering {
        if (this.first < right.first) {
            return Some(Ordering.LT)
        }
        if (this.first > right.first) {
            return Some(Ordering.GT)
        }
        if (this.first != right.first) {
            return None
        }
        if (this.second < right.second) {
            return Some(Ordering.LT)
        }
        if (this.second > right.second) {
            return Some(Ordering.GT)
        }
        if (this.second != right.second) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: DeriveCompileSmoke_DeriveCompileSmoke): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: DeriveCompileSmoke_DeriveCompileSmoke): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: DeriveCompileSmoke_DeriveCompileSmoke): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: DeriveCompileSmoke_DeriveCompileSmoke): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: DeriveCompileSmoke_DeriveCompileSmoke): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(first: Int32, second: Int32) {
        this.first = first
        this.second = second
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DeriveCompileSmoke_DeriveCompileSmoke>()
        if (size != 8) {
            throw Exception("Size of DeriveCompileSmoke_DeriveCompileSmoke is not 8 but ${size} bytes")
        }
        let align = alignOf<DeriveCompileSmoke_DeriveCompileSmoke>()
        if (align != 4) {
            throw Exception("Alignment of DeriveCompileSmoke_DeriveCompileSmoke is not 4 but ${align} bytes")
        }
}
