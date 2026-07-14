package cjbind_ffi

@C
public struct BlobFloatDerives_BlobFloatDerives {
    public let value: VArray<UInt32, $3>
    public let tail: Int32
    public func clone(): BlobFloatDerives_BlobFloatDerives {
        return this
    }
    public func toString(): String {
        var output = "BlobFloatDerives_BlobFloatDerives {"
        output += " value: "
        output += "<opaque float>"
        output += ", tail: "
        output += this.tail.toString()
        output += " }"
        return output
    }
    public operator func ==(right: BlobFloatDerives_BlobFloatDerives): Bool {
        for (__cjbindEqIndex0 in 0..3) {
            if (this.value[__cjbindEqIndex0] != right.value[__cjbindEqIndex0]) {
                return false
            }
        }
        if (this.tail != right.tail) {
            return false
        }
        return true
    }
    public operator func !=(right: BlobFloatDerives_BlobFloatDerives): Bool {
        return !(this == right)
    }
    public static func default(): BlobFloatDerives_BlobFloatDerives {
        return unsafe { zeroValue<BlobFloatDerives_BlobFloatDerives>() }
    }
    public func __cjbindPartialCompare(right: BlobFloatDerives_BlobFloatDerives): ?Ordering {
        for (__cjbindOrdIndex0 in 0..3) {
            if (this.value[__cjbindOrdIndex0] < right.value[__cjbindOrdIndex0]) {
                return Some(Ordering.LT)
            }
            if (this.value[__cjbindOrdIndex0] > right.value[__cjbindOrdIndex0]) {
                return Some(Ordering.GT)
            }
        }
        if (this.tail < right.tail) {
            return Some(Ordering.LT)
        }
        if (this.tail > right.tail) {
            return Some(Ordering.GT)
        }
        if (this.tail != right.tail) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: BlobFloatDerives_BlobFloatDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: BlobFloatDerives_BlobFloatDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: BlobFloatDerives_BlobFloatDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: BlobFloatDerives_BlobFloatDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public init(value: VArray<UInt32, $3>, tail: Int32) {
        this.value = value
        this.tail = tail
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BlobFloatDerives_BlobFloatDerives>()
        if (size != 16) {
            throw Exception("Size of BlobFloatDerives_BlobFloatDerives is not 16 but ${size} bytes")
        }
        let align = alignOf<BlobFloatDerives_BlobFloatDerives>()
        if (align != 4) {
            throw Exception("Alignment of BlobFloatDerives_BlobFloatDerives is not 4 but ${align} bytes")
        }
}
