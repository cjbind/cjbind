package cjbind_ffi

foreign func _ZNK5Outer5Inner3getEv(this_: CPointer<Outer_Inner>): Int32

public unsafe func Outer_Inner_get(this_: CPointer<Outer_Inner>): Int32 {
    return _ZNK5Outer5Inner3getEv(this_)
}

@C
public struct Outer_Inner {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Inner>()
        if (size != 4) {
            throw Exception("Size of Outer_Inner is not 4 but ${size} bytes")
        }
        let align = alignOf<Outer_Inner>()
        if (align != 4) {
            throw Exception("Alignment of Outer_Inner is not 4 but ${align} bytes")
        }
}

@C
public struct Outer {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer>()
        if (size != 4) {
            throw Exception("Size of Outer is not 4 but ${size} bytes")
        }
        let align = alignOf<Outer>()
        if (align != 4) {
            throw Exception("Alignment of Outer is not 4 but ${align} bytes")
        }
}

@C
public struct Outer_Deferred {
    public let payload: Int64
    public init(payload: Int64) {
        this.payload = payload
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Deferred>()
        if (size != 8) {
            throw Exception("Size of Outer_Deferred is not 8 but ${size} bytes")
        }
        let align = alignOf<Outer_Deferred>()
        if (align != 8) {
            throw Exception("Alignment of Outer_Deferred is not 8 but ${align} bytes")
        }
}

@C
public struct NestedHolder {
    public let inner: Outer_Inner
    public let deferred: CPointer<Outer_Deferred>
    public let boxed: Outer_Box_open0_int_close0
    public init(inner: Outer_Inner, deferred: CPointer<Outer_Deferred>, boxed: Outer_Box_open0_int_close0) {
        this.inner = inner
        this.deferred = deferred
        this.boxed = boxed
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<NestedHolder>()
        if (size != 24) {
            throw Exception("Size of NestedHolder is not 24 but ${size} bytes")
        }
        let align = alignOf<NestedHolder>()
        if (align != 8) {
            throw Exception("Alignment of NestedHolder is not 8 but ${align} bytes")
        }
}

foreign func _Z10pass_innerN5Outer5InnerE(value: Outer_Inner): Outer_Inner

public unsafe func pass_inner(value: Outer_Inner): Outer_Inner {
    return _Z10pass_innerN5Outer5InnerE(value)
}

@C
public struct Outer_Box_open0_int_close0 {
    let _cjbind_opaque_blob: UInt32
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<UInt32>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Outer_Box_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of Outer_Box_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<Outer_Box_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of Outer_Box_open0_int_close0 is not 4 but ${align} bytes")
        }
}
