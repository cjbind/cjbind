package cjbind_ffi

foreign func _ZN13RecursiveBase9asDerivedEv(this_: CPointer<RecursiveBase_RecursiveBase>): CPointer<RecursiveDerived_RecursiveDerived>

public unsafe func RecursiveBase_asDerived(this_: CPointer<RecursiveBase_RecursiveBase>): CPointer<RecursiveDerived_RecursiveDerived> {
    return _ZN13RecursiveBase9asDerivedEv(this_)
}

foreign func _ZN13RecursiveBase6updateEc(this_: CPointer<RecursiveBase_RecursiveBase>, value: UInt8): Unit

public unsafe func RecursiveBase_update(this_: CPointer<RecursiveBase_RecursiveBase>, value: UInt8): Unit {
    return _ZN13RecursiveBase6updateEc(this_, value)
}

foreign func _ZN13RecursiveBase6updateEi(this_: CPointer<RecursiveBase_RecursiveBase>, value: Int32): Unit

public unsafe func RecursiveBase_update1(this_: CPointer<RecursiveBase_RecursiveBase>, value: Int32): Unit {
    return _ZN13RecursiveBase6updateEi(this_, value)
}

foreign func _ZN13RecursiveBaseD1Ev(this_: CPointer<RecursiveBase_RecursiveBase>): Unit

public unsafe func RecursiveBase_RecursiveBase_destructor(this_: CPointer<RecursiveBase_RecursiveBase>): Unit {
    return _ZN13RecursiveBaseD1Ev(this_)
}

@C
public struct RecursiveBase_RecursiveBase {
    public let vtable_: CPointer<Unit>
    public func toString(): String {
        var output = "RecursiveBase_RecursiveBase {"
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
        let size = sizeOf<RecursiveBase_RecursiveBase>()
        if (size != 8) {
            throw Exception("Size of RecursiveBase_RecursiveBase is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveBase_RecursiveBase>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveBase_RecursiveBase is not 8 but ${align} bytes")
        }
}

foreign func _ZN16RecursiveDerived9asDerivedEv(this_: CPointer<RecursiveDerived_RecursiveDerived>): CPointer<RecursiveDerived_RecursiveDerived>

public unsafe func RecursiveDerived_asDerived(this_: CPointer<RecursiveDerived_RecursiveDerived>): CPointer<RecursiveDerived_RecursiveDerived> {
    return _ZN16RecursiveDerived9asDerivedEv(this_)
}

foreign func _ZN16RecursiveDerived6updateEc(this_: CPointer<RecursiveDerived_RecursiveDerived>, value: UInt8): Unit

public unsafe func RecursiveDerived_update(this_: CPointer<RecursiveDerived_RecursiveDerived>, value: UInt8): Unit {
    return _ZN16RecursiveDerived6updateEc(this_, value)
}

foreign func _ZN16RecursiveDerived6updateEi(this_: CPointer<RecursiveDerived_RecursiveDerived>, value: Int32): Unit

public unsafe func RecursiveDerived_update1(this_: CPointer<RecursiveDerived_RecursiveDerived>, value: Int32): Unit {
    return _ZN16RecursiveDerived6updateEi(this_, value)
}

@C
public struct RecursiveDerived_RecursiveDerived {
    public let _base: RecursiveBase_RecursiveBase
    public func toString(): String {
        var output = "RecursiveDerived_RecursiveDerived {"
        output += " _base: "
        output += this._base.toString()
        output += " }"
        return output
    }
    public init(_base: RecursiveBase_RecursiveBase) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<RecursiveDerived_RecursiveDerived>()
        if (size != 8) {
            throw Exception("Size of RecursiveDerived_RecursiveDerived is not 8 but ${size} bytes")
        }
        let align = alignOf<RecursiveDerived_RecursiveDerived>()
        if (align != 8) {
            throw Exception("Alignment of RecursiveDerived_RecursiveDerived is not 8 but ${align} bytes")
        }
}

foreign func _ZN9Secondary9secondaryEv(this_: CPointer<Secondary_Secondary>): Int32

public unsafe func Secondary_secondary(this_: CPointer<Secondary_Secondary>): Int32 {
    return _ZN9Secondary9secondaryEv(this_)
}

@C
public struct Secondary_Secondary__cjbind_vtable {
    public let Secondary_secondary: CFunc<(this_: CPointer<Secondary_Secondary>) -> Int32>
    public init(Secondary_secondary: CFunc<(this_: CPointer<Secondary_Secondary>) -> Int32>) {
        this.Secondary_secondary = Secondary_secondary
    }
}

@C
public struct Secondary_Secondary {
    public let vtable_: CPointer<Secondary_Secondary__cjbind_vtable>
    public func clone(): Secondary_Secondary {
        return this
    }
    public func toString(): String {
        var output = "Secondary_Secondary {"
        output += " vtable_: "
        output += CPointer<Unit>(this.vtable_).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(vtable_: CPointer<Secondary_Secondary__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Secondary_Secondary>()
        if (size != 8) {
            throw Exception("Size of Secondary_Secondary is not 8 but ${size} bytes")
        }
        let align = alignOf<Secondary_Secondary>()
        if (align != 8) {
            throw Exception("Alignment of Secondary_Secondary is not 8 but ${align} bytes")
        }
}

foreign func _ZN17MultipleInterface9secondaryEv(this_: CPointer<MultipleInterface_MultipleInterface>): Int32

public unsafe func MultipleInterface_secondary(this_: CPointer<MultipleInterface_MultipleInterface>): Int32 {
    return _ZN17MultipleInterface9secondaryEv(this_)
}

@C
public struct MultipleInterface_MultipleInterface {
    public let _base: RecursiveDerived_RecursiveDerived
    public let _base_1: Secondary_Secondary
    public func toString(): String {
        var output = "MultipleInterface_MultipleInterface {"
        output += " _base: "
        output += this._base.toString()
        output += ", _base_1: "
        output += this._base_1.toString()
        output += " }"
        return output
    }
    public init(_base: RecursiveDerived_RecursiveDerived, _base_1: Secondary_Secondary) {
        this._base = _base
        this._base_1 = _base_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MultipleInterface_MultipleInterface>()
        if (size != 16) {
            throw Exception("Size of MultipleInterface_MultipleInterface is not 16 but ${size} bytes")
        }
        let align = alignOf<MultipleInterface_MultipleInterface>()
        if (align != 8) {
            throw Exception("Alignment of MultipleInterface_MultipleInterface is not 8 but ${align} bytes")
        }
}
