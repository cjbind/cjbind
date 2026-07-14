package cjbind_ffi

foreign func _ZNK5Outer5Inner3getEv(this_: CPointer<Outer_Inner_Inner>): Int32

public unsafe func Outer_Inner_get(this_: CPointer<Outer_Inner_Inner>): Int32 {
    return _ZNK5Outer5Inner3getEv(this_)
}

@C
public struct Outer_Inner_Inner {
    public let value: Int32
    public func clone(): Outer_Inner_Inner {
        return this
    }
    public func toString(): String {
        var output = "Outer_Inner_Inner {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Inner_Inner>()
        if (size != 4) {
            throw Exception("Size of Outer_Inner_Inner is not 4 but ${size} bytes")
        }
        let align = alignOf<Outer_Inner_Inner>()
        if (align != 4) {
            throw Exception("Alignment of Outer_Inner_Inner is not 4 but ${align} bytes")
        }
}

@C
public struct Outer_Outer {
    public let value: Int32
    public func clone(): Outer_Outer {
        return this
    }
    public func toString(): String {
        var output = "Outer_Outer {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Outer>()
        if (size != 4) {
            throw Exception("Size of Outer_Outer is not 4 but ${size} bytes")
        }
        let align = alignOf<Outer_Outer>()
        if (align != 4) {
            throw Exception("Alignment of Outer_Outer is not 4 but ${align} bytes")
        }
}

@C
public struct Outer_Deferred_Deferred {
    public let payload: Int64
    public func clone(): Outer_Deferred_Deferred {
        return this
    }
    public func toString(): String {
        var output = "Outer_Deferred_Deferred {"
        output += " payload: "
        output += this.payload.toString()
        output += " }"
        return output
    }
    public init(payload: Int64) {
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Deferred_Deferred>()
        if (size != 8) {
            throw Exception("Size of Outer_Deferred_Deferred is not 8 but ${size} bytes")
        }
        let align = alignOf<Outer_Deferred_Deferred>()
        if (align != 8) {
            throw Exception("Alignment of Outer_Deferred_Deferred is not 8 but ${align} bytes")
        }
}

@C
public struct Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0 {
    public let value: Int32
    public func clone(): Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0 {
        return this
    }
    public func toString(): String {
        var output = "Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0 {"
        output += " value: "
        output += this.value.toString()
        output += " }"
        return output
    }
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct NestedHolder_NestedHolder {
    public let inner: Outer_Inner_Inner
    public let deferred: CPointer<Outer_Deferred_Deferred>
    public let boxed: Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0
    public func clone(): NestedHolder_NestedHolder {
        return this
    }
    public func toString(): String {
        var output = "NestedHolder_NestedHolder {"
        output += " inner: "
        output += this.inner.toString()
        output += ", deferred: "
        output += CPointer<Unit>(this.deferred).toUIntNative().toString()
        output += ", boxed: "
        output += this.boxed.toString()
        output += " }"
        return output
    }
    public init(inner: Outer_Inner_Inner, deferred: CPointer<Outer_Deferred_Deferred>,
        boxed: Outer_Outer_Box_open0_int_close0_Outer_Box_open0_int_close0) {
        this.inner = inner
        this.deferred = deferred
        this.boxed = boxed
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedHolder_NestedHolder>()
        if (size != 24) {
            throw Exception("Size of NestedHolder_NestedHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<NestedHolder_NestedHolder>()
        if (align != 8) {
            throw Exception("Alignment of NestedHolder_NestedHolder is not 8 but ${align} bytes")
        }
}

foreign func _Z10pass_innerN5Outer5InnerE(value: Outer_Inner_Inner): Outer_Inner_Inner

public unsafe func pass_inner(value: Outer_Inner_Inner): Outer_Inner_Inner {
    return _Z10pass_innerN5Outer5InnerE(value)
}
