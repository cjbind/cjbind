package cjbind_ffi

foreign func _ZN14LifecycleProbeC1Ev(this_: CPointer<LifecycleProbe>): Unit

public unsafe func LifecycleProbe_constructor(this_: CPointer<LifecycleProbe>): Unit {
    return _ZN14LifecycleProbeC1Ev(this_)
}

foreign func _ZN14LifecycleProbeC1Ei(this_: CPointer<LifecycleProbe>, value: Int32): Unit

public unsafe func LifecycleProbe_constructor1(this_: CPointer<LifecycleProbe>, value: Int32): Unit {
    return _ZN14LifecycleProbeC1Ei(this_, value)
}

foreign func _ZN14LifecycleProbeD1Ev(this_: CPointer<LifecycleProbe>): Unit

public unsafe func LifecycleProbe_LifecycleProbe_destructor(this_: CPointer<LifecycleProbe>): Unit {
    return _ZN14LifecycleProbeD1Ev(this_)
}

foreign func _ZNK14LifecycleProbe5valueEv(this_: CPointer<LifecycleProbe>): Int32

public unsafe func LifecycleProbe_value(this_: CPointer<LifecycleProbe>): Int32 {
    return _ZNK14LifecycleProbe5valueEv(this_)
}

foreign func _ZN14LifecycleProbe3addEii(left: Int32, right: Int32): Int32

public unsafe func LifecycleProbe_add(left: Int32, right: Int32): Int32 {
    return _ZN14LifecycleProbe3addEii(left, right)
}

@C
public struct LifecycleProbe {
    private let stored_: Int32
    private init(stored_: Int32) {
        this.stored_ = stored_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<LifecycleProbe>()
        if (size != 4) {
            throw Exception("Size of LifecycleProbe is not 4 but ${size} bytes")
        }
        let align = alignOf<LifecycleProbe>()
        if (align != 4) {
            throw Exception("Alignment of LifecycleProbe is not 4 but ${align} bytes")
        }
}

foreign func lifecycle_live_count(): Int32

foreign func _ZN11RuntimeLeftC1Ev(this_: CPointer<RuntimeLeft>): Unit

public unsafe func RuntimeLeft_constructor(this_: CPointer<RuntimeLeft>): Unit {
    return _ZN11RuntimeLeftC1Ev(this_)
}

foreign func _ZNK11RuntimeLeft4leftEv(this_: CPointer<RuntimeLeft>): Int32

public unsafe func RuntimeLeft_left(this_: CPointer<RuntimeLeft>): Int32 {
    return _ZNK11RuntimeLeft4leftEv(this_)
}

@C
public struct RuntimeLeft {
    public let vtable_: CPointer<Unit>
    private let padding_: Int32
    private init(vtable_: CPointer<Unit>, padding_: Int32) {
        this.vtable_ = vtable_
        this.padding_ = padding_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RuntimeLeft>()
        if (size != 16) {
            throw Exception("Size of RuntimeLeft is not 16 but ${size} bytes")
        }
        let align = alignOf<RuntimeLeft>()
        if (align != 8) {
            throw Exception("Alignment of RuntimeLeft is not 8 but ${align} bytes")
        }
}

foreign func _ZN12RuntimeRightC1Ev(this_: CPointer<RuntimeRight>): Unit

public unsafe func RuntimeRight_constructor(this_: CPointer<RuntimeRight>): Unit {
    return _ZN12RuntimeRightC1Ev(this_)
}

foreign func _ZNK12RuntimeRight5rightEv(this_: CPointer<RuntimeRight>): Int32

public unsafe func RuntimeRight_right(this_: CPointer<RuntimeRight>): Int32 {
    return _ZNK12RuntimeRight5rightEv(this_)
}

@C
public struct RuntimeRight {
    public let vtable_: CPointer<Unit>
    public init(vtable_: CPointer<Unit>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RuntimeRight>()
        if (size != 8) {
            throw Exception("Size of RuntimeRight is not 8 but ${size} bytes")
        }
        let align = alignOf<RuntimeRight>()
        if (align != 8) {
            throw Exception("Alignment of RuntimeRight is not 8 but ${align} bytes")
        }
}

foreign func _ZN13MultipleProbeC1Ei(this_: CPointer<MultipleProbe>, value: Int32): Unit

public unsafe func MultipleProbe_constructor(this_: CPointer<MultipleProbe>, value: Int32): Unit {
    return _ZN13MultipleProbeC1Ei(this_, value)
}

foreign func _ZN13MultipleProbeD1Ev(this_: CPointer<MultipleProbe>): Unit

public unsafe func MultipleProbe_MultipleProbe_destructor(this_: CPointer<MultipleProbe>): Unit {
    return _ZN13MultipleProbeD1Ev(this_)
}

foreign func _ZNK13MultipleProbe4leftEv(this_: CPointer<MultipleProbe>): Int32

public unsafe func MultipleProbe_left(this_: CPointer<MultipleProbe>): Int32 {
    return _ZNK13MultipleProbe4leftEv(this_)
}

foreign func _ZNK13MultipleProbe5rightEv(this_: CPointer<MultipleProbe>): Int32

public unsafe func MultipleProbe_right(this_: CPointer<MultipleProbe>): Int32 {
    return _ZNK13MultipleProbe5rightEv(this_)
}

@C
public struct MultipleProbe {
    public let _base: RuntimeLeft
    public let _base_1: RuntimeRight
    private let stored_: Int32
    private init(_base: RuntimeLeft, _base_1: RuntimeRight, stored_: Int32) {
        this._base = _base
        this._base_1 = _base_1
        this.stored_ = stored_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MultipleProbe>()
        if (size != 32) {
            throw Exception("Size of MultipleProbe is not 32 but ${size} bytes")
        }
        let align = alignOf<MultipleProbe>()
        if (align != 8) {
            throw Exception("Alignment of MultipleProbe is not 8 but ${align} bytes")
        }
}
