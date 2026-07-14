package cjbind_ffi

@C
public struct DerivedWithoutNewVirtual {
    public let _base: BaseWithVtable_open0_ptr_char_close0
    public init(_base: BaseWithVtable_open0_ptr_char_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithoutNewVirtual>()
        if (size != 16) {
            throw Exception("Size of DerivedWithoutNewVirtual is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedWithoutNewVirtual>()
        if (align != 8) {
            throw Exception("Alignment of DerivedWithoutNewVirtual is not 8 but ${align} bytes")
        }
}

foreign func _ZN18DerivedWithVirtual5extraEv(this_: CPointer<Unit>): Int32

public unsafe func DerivedWithVirtual_extra(this_: CPointer<Unit>): Int32 {
    return _ZN18DerivedWithVirtual5extraEv(this_)
}

@C
public struct DerivedWithVirtual {
    public let _base: BaseWithVtable_open0_ptr_char_close0
    public init(_base: BaseWithVtable_open0_ptr_char_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithVirtual>()
        if (size != 16) {
            throw Exception("Size of DerivedWithVirtual is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedWithVirtual>()
        if (align != 8) {
            throw Exception("Alignment of DerivedWithVirtual is not 8 but ${align} bytes")
        }
}

@C
public struct PlainDerived {
    public let _base: PlainBase_open0_int_close0
    public let tag: Int16
    public init(_base: PlainBase_open0_int_close0, tag: Int16) {
        this._base = _base
        this.tag = tag
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PlainDerived>()
        if (size != 8) {
            throw Exception("Size of PlainDerived is not 8 but ${size} bytes")
        }
        let align = alignOf<PlainDerived>()
        if (align != 4) {
            throw Exception("Alignment of PlainDerived is not 4 but ${align} bytes")
        }
}

@C
public struct PlainBase_open0_int_close0 {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PlainBase_open0_int_close0>()
        if (size != 4) {
            throw Exception("Size of PlainBase_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<PlainBase_open0_int_close0>()
        if (align != 4) {
            throw Exception("Alignment of PlainBase_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct BaseWithVtable_open0_ptr_char_close0 {
    let _cjbind_opaque_blob: VArray<UInt64, $2>
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt64, $2>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<BaseWithVtable_open0_ptr_char_close0>()
        if (size != 16) {
            throw Exception("Size of BaseWithVtable_open0_ptr_char_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<BaseWithVtable_open0_ptr_char_close0>()
        if (align != 8) {
            throw Exception("Alignment of BaseWithVtable_open0_ptr_char_close0 is not 8 but ${align} bytes")
        }
}
