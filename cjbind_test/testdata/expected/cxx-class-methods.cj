package cjbind_ffi

foreign func _ZN6WidgetC1Ev(this_: CPointer<Widget>): Unit

public unsafe func Widget_constructor(this_: CPointer<Widget>): Unit {
    return _ZN6WidgetC1Ev(this_)
}

foreign func _ZN6WidgetC1Ei(this_: CPointer<Widget>, initial: Int32): Unit

public unsafe func Widget_constructor1(this_: CPointer<Widget>, initial: Int32): Unit {
    return _ZN6WidgetC1Ei(this_, initial)
}

foreign func _ZN6WidgetD1Ev(this_: CPointer<Widget>): Unit

public unsafe func Widget_Widget_destructor(this_: CPointer<Widget>): Unit {
    return _ZN6WidgetD1Ev(this_)
}

foreign func _ZNK6Widget3getEv(this_: CPointer<Widget>): Int32

public unsafe func Widget_get(this_: CPointer<Widget>): Int32 {
    return _ZNK6Widget3getEv(this_)
}

foreign func _ZN6Widget3setEi(this_: CPointer<Widget>, next: Int32): Unit

public unsafe func Widget_set(this_: CPointer<Widget>, next: Int32): Unit {
    return _ZN6Widget3setEi(this_, next)
}

foreign func _ZN6Widget5twiceEi(input: Int32): Int32

public unsafe func Widget_twice(input: Int32): Int32 {
    return _ZN6Widget5twiceEi(input)
}

@C
public struct Widget {
    private let value: Int32
    private init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Widget>()
        if (size != 4) {
            throw Exception("Size of Widget is not 4 but ${size} bytes")
        }
        let align = alignOf<Widget>()
        if (align != 4) {
            throw Exception("Alignment of Widget is not 4 but ${align} bytes")
        }
}

foreign func _Z10overloadedi(input: Int32): Int32

public unsafe func overloaded(input: Int32): Int32 {
    return _Z10overloadedi(input)
}

foreign func _Z10overloadedd(input: Float64): Float64

public unsafe func overloaded1(input: Float64): Float64 {
    return _Z10overloadedd(input)
}

foreign func _ZN1C1EC1Ev(this_: CPointer<C_E>): Unit

public unsafe func C_E_constructor(this_: CPointer<C_E>): Unit {
    return _ZN1C1EC1Ev(this_)
}

@C
public struct C_E {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<C_E>()
        if (size != 1) {
            throw Exception("Size of C_E is not 1 but ${size} bytes")
        }
        let align = alignOf<C_E>()
        if (align != 1) {
            throw Exception("Alignment of C_E is not 1 but ${align} bytes")
        }
}

foreign func _ZN1D1ED1Ev(this_: CPointer<D_E>): Unit

public unsafe func D_E_E_destructor(this_: CPointer<D_E>): Unit {
    return _ZN1D1ED1Ev(this_)
}

@C
public struct D_E {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<D_E>()
        if (size != 1) {
            throw Exception("Size of D_E is not 1 but ${size} bytes")
        }
        let align = alignOf<D_E>()
        if (align != 1) {
            throw Exception("Alignment of D_E is not 1 but ${align} bytes")
        }
}

@C
public struct ManglingArgument {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ManglingArgument>()
        if (size != 1) {
            throw Exception("Size of ManglingArgument is not 1 but ${size} bytes")
        }
        let align = alignOf<ManglingArgument>()
        if (align != 1) {
            throw Exception("Alignment of ManglingArgument is not 1 but ${align} bytes")
        }
}
