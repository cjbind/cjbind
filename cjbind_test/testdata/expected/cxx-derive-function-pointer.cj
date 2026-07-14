package cjbind_ffi

public type DeriveCallback_DeriveCallback = CFunc<(value: Int32) -> Int32>

@C
public struct FunctionPointerDerives_FunctionPointerDerives {
    public let callback: DeriveCallback_DeriveCallback
    public func clone(): FunctionPointerDerives_FunctionPointerDerives {
        return this
    }
    public func toString(): String {
        var output = "FunctionPointerDerives_FunctionPointerDerives {"
        output += " callback: "
        output += CPointer<Unit>(this.callback).toUIntNative().toString()
        output += " }"
        return output
    }
    public operator func ==(right: FunctionPointerDerives_FunctionPointerDerives): Bool {
        if (CPointer<Unit>(this.callback).toUIntNative() != CPointer<Unit>(right.callback).toUIntNative()) {
            return false
        }
        return true
    }
    public operator func !=(right: FunctionPointerDerives_FunctionPointerDerives): Bool {
        return !(this == right)
    }
    public static func default(): FunctionPointerDerives_FunctionPointerDerives {
        return unsafe { zeroValue<FunctionPointerDerives_FunctionPointerDerives>() }
    }
    public func hashCode(): Int64 {
        var hash = 1469598103934665603i64
        hash = ((hash << 5) | (hash >> 59)) ^ CPointer<Unit>(this.callback).toUIntNative().hashCode()
        return hash
    }
    public func __cjbindPartialCompare(right: FunctionPointerDerives_FunctionPointerDerives): ?Ordering {
        if (CPointer<Unit>(this.callback).toUIntNative() < CPointer<Unit>(right.callback).toUIntNative()) {
            return Some(Ordering.LT)
        }
        if (CPointer<Unit>(this.callback).toUIntNative() > CPointer<Unit>(right.callback).toUIntNative()) {
            return Some(Ordering.GT)
        }
        if (CPointer<Unit>(this.callback).toUIntNative() != CPointer<Unit>(right.callback).toUIntNative()) {
            return None
        }
        return Some(Ordering.EQ)
    }
    public operator func <(right: FunctionPointerDerives_FunctionPointerDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) => true
            case _ => false
        }
    }
    public operator func <=(right: FunctionPointerDerives_FunctionPointerDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.LT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public operator func >(right: FunctionPointerDerives_FunctionPointerDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) => true
            case _ => false
        }
    }
    public operator func >=(right: FunctionPointerDerives_FunctionPointerDerives): Bool {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(Ordering.GT) | Some(Ordering.EQ) => true
            case _ => false
        }
    }
    public func compare(right: FunctionPointerDerives_FunctionPointerDerives): Ordering {
        return match (this.__cjbindPartialCompare(right)) {
            case Some(value) => value
            case None => throw Exception("ordered comparison produced an unordered value")
        }
    }
    public init(callback: DeriveCallback_DeriveCallback) {
        this.callback = callback
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FunctionPointerDerives_FunctionPointerDerives>()
        if (size != 8) {
            throw Exception("Size of FunctionPointerDerives_FunctionPointerDerives is not 8 but ${size} bytes")
        }
        let align = alignOf<FunctionPointerDerives_FunctionPointerDerives>()
        if (align != 8) {
            throw Exception("Alignment of FunctionPointerDerives_FunctionPointerDerives is not 8 but ${align} bytes")
        }
}
