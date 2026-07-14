package cjbind_ffi

foreign func _ZN13RecursiveBase9asDerivedEv(this_: CPointer<RecursiveBase>): CPointer<RecursiveDerived>

public unsafe func RecursiveBase_asDerived(this_: CPointer<RecursiveBase>): CPointer<RecursiveDerived> {
    return _ZN13RecursiveBase9asDerivedEv(this_)
}

foreign func _ZN13RecursiveBase6updateEc(this_: CPointer<RecursiveBase>, value: UInt8): Unit

public unsafe func RecursiveBase_update(this_: CPointer<RecursiveBase>, value: UInt8): Unit {
    return _ZN13RecursiveBase6updateEc(this_, value)
}

foreign func _ZN13RecursiveBase6updateEi(this_: CPointer<RecursiveBase>, value: Int32): Unit

public unsafe func RecursiveBase_update1(this_: CPointer<RecursiveBase>, value: Int32): Unit {
    return _ZN13RecursiveBase6updateEi(this_, value)
}

foreign func _ZN13RecursiveBaseD1Ev(this_: CPointer<RecursiveBase>): Unit

public unsafe func RecursiveBase_RecursiveBase_destructor(this_: CPointer<RecursiveBase>): Unit {
    return _ZN13RecursiveBaseD1Ev(this_)
}

@C
public struct RecursiveBase {
    public let vtable_: CPointer<Unit>
    public init(vtable_: CPointer<Unit>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecursiveBase>()
        if (size != 8) {
            throw Exception("Size of RecursiveBase is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveBase>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveBase is not 8 but ${align} bytes")
        }
}

foreign func _ZN16RecursiveDerived9asDerivedEv(this_: CPointer<RecursiveDerived>): CPointer<RecursiveDerived>

public unsafe func RecursiveDerived_asDerived(this_: CPointer<RecursiveDerived>): CPointer<RecursiveDerived> {
    return _ZN16RecursiveDerived9asDerivedEv(this_)
}

foreign func _ZN16RecursiveDerived6updateEc(this_: CPointer<RecursiveDerived>, value: UInt8): Unit

public unsafe func RecursiveDerived_update(this_: CPointer<RecursiveDerived>, value: UInt8): Unit {
    return _ZN16RecursiveDerived6updateEc(this_, value)
}

foreign func _ZN16RecursiveDerived6updateEi(this_: CPointer<RecursiveDerived>, value: Int32): Unit

public unsafe func RecursiveDerived_update1(this_: CPointer<RecursiveDerived>, value: Int32): Unit {
    return _ZN16RecursiveDerived6updateEi(this_, value)
}

@C
public struct RecursiveDerived {
    public let _base: RecursiveBase
    public init(_base: RecursiveBase) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecursiveDerived>()
        if (size != 8) {
            throw Exception("Size of RecursiveDerived is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveDerived>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveDerived is not 8 but ${align} bytes")
        }
}

foreign func _ZN9Secondary9secondaryEv(this_: CPointer<Secondary>): Int32

public unsafe func Secondary_secondary(this_: CPointer<Secondary>): Int32 {
    return _ZN9Secondary9secondaryEv(this_)
}

@C
public struct Secondary__cjbind_vtable {
    public let Secondary_secondary: CFunc<(this_: CPointer<Secondary>) -> Int32>
    public init(Secondary_secondary: CFunc<(this_: CPointer<Secondary>) -> Int32>) {
        this.Secondary_secondary = Secondary_secondary
    }
}

@C
public struct Secondary {
    public let vtable_: CPointer<Secondary__cjbind_vtable>
    public init(vtable_: CPointer<Secondary__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Secondary>()
        if (size != 8) {
            throw Exception("Size of Secondary is not 8 but ${size} bytes")
        }
        let align = alignOf<Secondary>()
        if (align != 8) {
            throw Exception("Alignment of Secondary is not 8 but ${align} bytes")
        }
}

foreign func _ZN17MultipleInterface9secondaryEv(this_: CPointer<MultipleInterface>): Int32

public unsafe func MultipleInterface_secondary(this_: CPointer<MultipleInterface>): Int32 {
    return _ZN17MultipleInterface9secondaryEv(this_)
}

@C
public struct MultipleInterface {
    public let _base: RecursiveDerived
    public let _base_1: Secondary
    public init(_base: RecursiveDerived, _base_1: Secondary) {
        this._base = _base
        this._base_1 = _base_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MultipleInterface>()
        if (size != 16) {
            throw Exception("Size of MultipleInterface is not 16 but ${size} bytes")
        }
        let align = alignOf<MultipleInterface>()
        if (align != 8) {
            throw Exception("Alignment of MultipleInterface is not 8 but ${align} bytes")
        }
}
