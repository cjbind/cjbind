package cjbind_ffi

foreign func _ZN14LifecycleProbeC1Ev(this_: CPointer<LifecycleProbe_LifecycleProbe>): Unit

public unsafe func LifecycleProbe_LifecycleProbe_constructor(this_: CPointer<LifecycleProbe_LifecycleProbe>): Unit {
    return _ZN14LifecycleProbeC1Ev(this_)
}

foreign func _ZN14LifecycleProbeC1Ei(this_: CPointer<LifecycleProbe_LifecycleProbe>, value: Int32): Unit

public unsafe func LifecycleProbe_LifecycleProbe_constructor1(this_: CPointer<LifecycleProbe_LifecycleProbe>,
    value: Int32): Unit {
    return _ZN14LifecycleProbeC1Ei(this_, value)
}

foreign func _ZN14LifecycleProbeD1Ev(this_: CPointer<LifecycleProbe_LifecycleProbe>): Unit

public unsafe func LifecycleProbe_LifecycleProbe_destructor(this_: CPointer<LifecycleProbe_LifecycleProbe>): Unit {
    return _ZN14LifecycleProbeD1Ev(this_)
}

foreign func _ZNK14LifecycleProbe5valueEv(this_: CPointer<LifecycleProbe_LifecycleProbe>): Int32

public unsafe func LifecycleProbe_value(this_: CPointer<LifecycleProbe_LifecycleProbe>): Int32 {
    return _ZNK14LifecycleProbe5valueEv(this_)
}

foreign func _ZN14LifecycleProbe3addEii(left: Int32, right: Int32): Int32

public unsafe func LifecycleProbe_add(left: Int32, right: Int32): Int32 {
    return _ZN14LifecycleProbe3addEii(left, right)
}

@C
public struct LifecycleProbe_LifecycleProbe {
    private let stored_: Int32
    public func toString(): String {
        var output = "LifecycleProbe_LifecycleProbe {"
        output += " stored_: "
        output += this.stored_.toString()
        output += " }"
        return output
    }
    private init(stored_: Int32) {
        this.stored_ = stored_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<LifecycleProbe_LifecycleProbe>()
        if (size != 4) {
            throw Exception("Size of LifecycleProbe_LifecycleProbe is not 4 but ${size} bytes")
        }
        let align = alignOf<LifecycleProbe_LifecycleProbe>()
        if (align != 4) {
            throw Exception("Alignment of LifecycleProbe_LifecycleProbe is not 4 but ${align} bytes")
        }
}

foreign func lifecycle_live_count(): Int32

foreign func _ZN11RuntimeLeftC1Ev(this_: CPointer<RuntimeLeft_RuntimeLeft>): Unit

public unsafe func RuntimeLeft_RuntimeLeft_constructor(this_: CPointer<RuntimeLeft_RuntimeLeft>): Unit {
    return _ZN11RuntimeLeftC1Ev(this_)
}

foreign func _ZNK11RuntimeLeft4leftEv(this_: CPointer<RuntimeLeft_RuntimeLeft>): Int32

public unsafe func RuntimeLeft_left(this_: CPointer<RuntimeLeft_RuntimeLeft>): Int32 {
    return _ZNK11RuntimeLeft4leftEv(this_)
}

@C
public struct RuntimeLeft_RuntimeLeft {
    public let vtable_: CPointer<Unit>
    private let padding_: Int32
    public func clone(): RuntimeLeft_RuntimeLeft {
        return this
    }
    public func toString(): String {
        var output = "RuntimeLeft_RuntimeLeft {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += ", padding_: "
        output += this.padding_.toString()
        output += " }"
        return output
    }
    private init(vtable_: CPointer<Unit>, padding_: Int32) {
        this.vtable_ = vtable_
        this.padding_ = padding_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RuntimeLeft_RuntimeLeft>()
        if (size != 16) {
            throw Exception("Size of RuntimeLeft_RuntimeLeft is not 16 but ${size} bytes")
        }
        let align = alignOf<RuntimeLeft_RuntimeLeft>()
        if (align != 8) {
            throw Exception("Alignment of RuntimeLeft_RuntimeLeft is not 8 but ${align} bytes")
        }
}

foreign func _ZN12RuntimeRightC1Ev(this_: CPointer<RuntimeRight_RuntimeRight>): Unit

public unsafe func RuntimeRight_RuntimeRight_constructor(this_: CPointer<RuntimeRight_RuntimeRight>): Unit {
    return _ZN12RuntimeRightC1Ev(this_)
}

foreign func _ZNK12RuntimeRight5rightEv(this_: CPointer<RuntimeRight_RuntimeRight>): Int32

public unsafe func RuntimeRight_right(this_: CPointer<RuntimeRight_RuntimeRight>): Int32 {
    return _ZNK12RuntimeRight5rightEv(this_)
}

@C
public struct RuntimeRight_RuntimeRight {
    public let vtable_: CPointer<Unit>
    public func clone(): RuntimeRight_RuntimeRight {
        return this
    }
    public func toString(): String {
        var output = "RuntimeRight_RuntimeRight {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(vtable_: CPointer<Unit>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RuntimeRight_RuntimeRight>()
        if (size != 8) {
            throw Exception("Size of RuntimeRight_RuntimeRight is not 8 but ${size} bytes")
        }
        let align = alignOf<RuntimeRight_RuntimeRight>()
        if (align != 8) {
            throw Exception("Alignment of RuntimeRight_RuntimeRight is not 8 but ${align} bytes")
        }
}

foreign func _ZN13MultipleProbeC1Ei(this_: CPointer<MultipleProbe_MultipleProbe>, value: Int32): Unit

public unsafe func MultipleProbe_MultipleProbe_constructor(this_: CPointer<MultipleProbe_MultipleProbe>, value: Int32): Unit {
    return _ZN13MultipleProbeC1Ei(this_, value)
}

foreign func _ZN13MultipleProbeD1Ev(this_: CPointer<MultipleProbe_MultipleProbe>): Unit

public unsafe func MultipleProbe_MultipleProbe_destructor(this_: CPointer<MultipleProbe_MultipleProbe>): Unit {
    return _ZN13MultipleProbeD1Ev(this_)
}

foreign func _ZNK13MultipleProbe4leftEv(this_: CPointer<MultipleProbe_MultipleProbe>): Int32

public unsafe func MultipleProbe_left(this_: CPointer<MultipleProbe_MultipleProbe>): Int32 {
    return _ZNK13MultipleProbe4leftEv(this_)
}

foreign func _ZNK13MultipleProbe5rightEv(this_: CPointer<MultipleProbe_MultipleProbe>): Int32

public unsafe func MultipleProbe_right(this_: CPointer<MultipleProbe_MultipleProbe>): Int32 {
    return _ZNK13MultipleProbe5rightEv(this_)
}

@C
public struct MultipleProbe_MultipleProbe {
    public let _base: RuntimeLeft_RuntimeLeft
    public let _base_1: RuntimeRight_RuntimeRight
    private let stored_: Int32
    public func toString(): String {
        var output = "MultipleProbe_MultipleProbe {"
        output += " _base: "
        output += this._base.toString()
        output += ", _base_1: "
        output += this._base_1.toString()
        output += ", stored_: "
        output += this.stored_.toString()
        output += " }"
        return output
    }
    private init(_base: RuntimeLeft_RuntimeLeft, _base_1: RuntimeRight_RuntimeRight, stored_: Int32) {
        this._base = _base
        this._base_1 = _base_1
        this.stored_ = stored_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MultipleProbe_MultipleProbe>()
        if (size != 32) {
            throw Exception("Size of MultipleProbe_MultipleProbe is not 32 but ${size} bytes")
        }
        let align = alignOf<MultipleProbe_MultipleProbe>()
        if (align != 8) {
            throw Exception("Alignment of MultipleProbe_MultipleProbe is not 8 but ${align} bytes")
        }
}
