package cjbind_ffi

foreign func _ZN4Base3runEi(this_: CPointer<Base_Base>, input: Int32): Int32

public unsafe func Base_run(this_: CPointer<Base_Base>, input: Int32): Int32 {
    return _ZN4Base3runEi(this_, input)
}

foreign func _ZN4BaseD1Ev(this_: CPointer<Base_Base>): Unit

public unsafe func Base_Base_destructor(this_: CPointer<Base_Base>): Unit {
    return _ZN4BaseD1Ev(this_)
}

@C
public struct Base_Base {
    public let vtable_: CPointer<Unit>
    public let base: Int32
    public init(vtable_: CPointer<Unit>, base: Int32) {
        this.vtable_ = vtable_
        this.base = base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Base_Base>()
        if (size != 16) {
            throw Exception("Size of Base_Base is not 16 but ${size} bytes")
        }
        let align = alignOf<Base_Base>()
        if (align != 8) {
            throw Exception("Alignment of Base_Base is not 8 but ${align} bytes")
        }
}

@C
public struct Extra_Extra {
    public let extra: Int64
    public init(extra: Int64) {
        this.extra = extra
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Extra_Extra>()
        if (size != 8) {
            throw Exception("Size of Extra_Extra is not 8 but ${size} bytes")
        }
        let align = alignOf<Extra_Extra>()
        if (align != 8) {
            throw Exception("Alignment of Extra_Extra is not 8 but ${align} bytes")
        }
}

foreign func _ZN7Derived3runEi(this_: CPointer<Derived_Derived>, input: Int32): Int32

public unsafe func Derived_run(this_: CPointer<Derived_Derived>, input: Int32): Int32 {
    return _ZN7Derived3runEi(this_, input)
}

@C
public struct Derived_Derived {
    public let _base: Base_Base
    public let _base_1: Extra_Extra
    public let value: Int32
    public init(_base: Base_Base, _base_1: Extra_Extra, value: Int32) {
        this._base = _base
        this._base_1 = _base_1
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Derived_Derived>()
        if (size != 32) {
            throw Exception("Size of Derived_Derived is not 32 but ${size} bytes")
        }
        let align = alignOf<Derived_Derived>()
        if (align != 8) {
            throw Exception("Alignment of Derived_Derived is not 8 but ${align} bytes")
        }
}

foreign func _ZN9Interface5applyEi(this_: CPointer<Interface_Interface>, input: Int32): Int32

public unsafe func Interface_apply(this_: CPointer<Interface_Interface>, input: Int32): Int32 {
    return _ZN9Interface5applyEi(this_, input)
}

@C
public struct Interface_Interface__cjbind_vtable {
    public let Interface_apply: CFunc<(this_: CPointer<Interface_Interface>, input: Int32) -> Int32>
    public init(Interface_apply: CFunc<(this_: CPointer<Interface_Interface>, input: Int32) -> Int32>) {
        this.Interface_apply = Interface_apply
    }
}

@C
public struct Interface_Interface {
    public let vtable_: CPointer<Interface_Interface__cjbind_vtable>
    public init(vtable_: CPointer<Interface_Interface__cjbind_vtable>) {
        this.vtable_ = vtable_
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Interface_Interface>()
        if (size != 8) {
            throw Exception("Size of Interface_Interface is not 8 but ${size} bytes")
        }
        let align = alignOf<Interface_Interface>()
        if (align != 8) {
            throw Exception("Alignment of Interface_Interface is not 8 but ${align} bytes")
        }
}

foreign func _ZN8TailBase3tagEv(this_: CPointer<TailBase_TailBase>): Int32

public unsafe func TailBase_tag(this_: CPointer<TailBase_TailBase>): Int32 {
    return _ZN8TailBase3tagEv(this_)
}

@C
public struct TailBase_TailBase__cjbind_vtable {
    public let TailBase_tag: CFunc<(this_: CPointer<TailBase_TailBase>) -> Int32>
    public init(TailBase_tag: CFunc<(this_: CPointer<TailBase_TailBase>) -> Int32>) {
        this.TailBase_tag = TailBase_tag
    }
}

@C
public struct TailBase_TailBase {
    public let vtable_: CPointer<TailBase_TailBase__cjbind_vtable>
    public let payload: Int32
    public let marker: UInt8
    public init(vtable_: CPointer<TailBase_TailBase__cjbind_vtable>, payload: Int32, marker: UInt8) {
        this.vtable_ = vtable_
        this.payload = payload
        this.marker = marker
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TailBase_TailBase>()
        if (size != 16) {
            throw Exception("Size of TailBase_TailBase is not 16 but ${size} bytes")
        }
        let align = alignOf<TailBase_TailBase>()
        if (align != 8) {
            throw Exception("Alignment of TailBase_TailBase is not 8 but ${align} bytes")
        }
}

foreign func _ZN11TailDerived3tagEv(this_: CPointer<TailDerived_TailDerived>): Int32

public unsafe func TailDerived_tag(this_: CPointer<TailDerived_TailDerived>): Int32 {
    return _ZN11TailDerived3tagEv(this_)
}

@C
public struct TailDerived_TailDerived {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<TailDerived_TailDerived>()
        if (size != 16) {
            throw Exception("Size of TailDerived_TailDerived is not 16 but ${size} bytes")
        }
        let align = alignOf<TailDerived_TailDerived>()
        if (align != 8) {
            throw Exception("Alignment of TailDerived_TailDerived is not 8 but ${align} bytes")
        }
}

@C
public struct Plain_Plain {
    public let plain: Int32
    public init(plain: Int32) {
        this.plain = plain
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Plain_Plain>()
        if (size != 4) {
            throw Exception("Size of Plain_Plain is not 4 but ${size} bytes")
        }
        let align = alignOf<Plain_Plain>()
        if (align != 4) {
            throw Exception("Alignment of Plain_Plain is not 4 but ${align} bytes")
        }
}

foreign func _ZN4Poly3actEv(this_: CPointer<Poly_Poly>): Int32

public unsafe func Poly_act(this_: CPointer<Poly_Poly>): Int32 {
    return _ZN4Poly3actEv(this_)
}

@C
public struct Poly_Poly__cjbind_vtable {
    public let Poly_act: CFunc<(this_: CPointer<Poly_Poly>) -> Int32>
    public init(Poly_act: CFunc<(this_: CPointer<Poly_Poly>) -> Int32>) {
        this.Poly_act = Poly_act
    }
}

@C
public struct Poly_Poly {
    public let vtable_: CPointer<Poly_Poly__cjbind_vtable>
    public let poly: Int32
    public init(vtable_: CPointer<Poly_Poly__cjbind_vtable>, poly: Int32) {
        this.vtable_ = vtable_
        this.poly = poly
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Poly_Poly>()
        if (size != 16) {
            throw Exception("Size of Poly_Poly is not 16 but ${size} bytes")
        }
        let align = alignOf<Poly_Poly>()
        if (align != 8) {
            throw Exception("Alignment of Poly_Poly is not 8 but ${align} bytes")
        }
}

@C
public struct Reordered_Reordered {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<Reordered_Reordered>()
        if (size != 16) {
            throw Exception("Size of Reordered_Reordered is not 16 but ${size} bytes")
        }
        let align = alignOf<Reordered_Reordered>()
        if (align != 8) {
            throw Exception("Alignment of Reordered_Reordered is not 8 but ${align} bytes")
        }
}

@C
public struct VirtualBase_VirtualBase {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualBase_VirtualBase>()
        if (size != 4) {
            throw Exception("Size of VirtualBase_VirtualBase is not 4 but ${size} bytes")
        }
        let align = alignOf<VirtualBase_VirtualBase>()
        if (align != 4) {
            throw Exception("Alignment of VirtualBase_VirtualBase is not 4 but ${align} bytes")
        }
}

@C
public struct VirtualDerived_VirtualDerived {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<VirtualDerived_VirtualDerived>()
        if (size != 16) {
            throw Exception("Size of VirtualDerived_VirtualDerived is not 16 but ${size} bytes")
        }
        let align = alignOf<VirtualDerived_VirtualDerived>()
        if (align != 8) {
            throw Exception("Alignment of VirtualDerived_VirtualDerived is not 8 but ${align} bytes")
        }
}
