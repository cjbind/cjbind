package cjbind_ffi

@C
public struct DerivedWithoutNewVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 {
    public let vtable_: CPointer<Unit>
    public let item: CPointer<UInt8>
    public init(vtable_: CPointer<Unit>, item: CPointer<UInt8>) {
        this.vtable_ = vtable_
        this.item = item
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithoutNewVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0>()
        if (size != 16) {
            throw Exception(
                "Size of DerivedWithoutNewVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedWithoutNewVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of DerivedWithoutNewVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 is not 8 but ${align} bytes")
        }
}

@C
public struct DerivedWithoutNewVirtual_DerivedWithoutNewVirtual {
    public let _base: DerivedWithoutNewVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0
    public init(
        _base: DerivedWithoutNewVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithoutNewVirtual_DerivedWithoutNewVirtual>()
        if (size != 16) {
            throw Exception("Size of DerivedWithoutNewVirtual_DerivedWithoutNewVirtual is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedWithoutNewVirtual_DerivedWithoutNewVirtual>()
        if (align != 8) {
            throw Exception(
                "Alignment of DerivedWithoutNewVirtual_DerivedWithoutNewVirtual is not 8 but ${align} bytes")
        }
}

@C
public struct DerivedWithVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 {
    public let vtable_: CPointer<Unit>
    public let item: CPointer<UInt8>
    public init(vtable_: CPointer<Unit>, item: CPointer<UInt8>) {
        this.vtable_ = vtable_
        this.item = item
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0>()
        if (size != 16) {
            throw Exception(
                "Size of DerivedWithVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedWithVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0>()
        if (align != 8) {
            throw Exception(
                "Alignment of DerivedWithVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0 is not 8 but ${align} bytes")
        }
}

foreign func _ZN18DerivedWithVirtual5extraEv(this_: CPointer<Unit>): Int32

public unsafe func DerivedWithVirtual_extra(this_: CPointer<Unit>): Int32 {
    return _ZN18DerivedWithVirtual5extraEv(this_)
}

@C
public struct DerivedWithVirtual_DerivedWithVirtual {
    public let _base: DerivedWithVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0
    public init(_base: DerivedWithVirtual_BaseWithVtable_open0_char_ptr_close0_BaseWithVtable_open0_char_ptr_close0) {
        this._base = _base
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<DerivedWithVirtual_DerivedWithVirtual>()
        if (size != 16) {
            throw Exception("Size of DerivedWithVirtual_DerivedWithVirtual is not 16 but ${size} bytes")
        }
        let align = alignOf<DerivedWithVirtual_DerivedWithVirtual>()
        if (align != 8) {
            throw Exception("Alignment of DerivedWithVirtual_DerivedWithVirtual is not 8 but ${align} bytes")
        }
}

@C
public struct PlainDerived_PlainBase_open0_int_close0_PlainBase_open0_int_close0 {
    public let value: Int32
    public init(value: Int32) {
        this.value = value
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PlainDerived_PlainBase_open0_int_close0_PlainBase_open0_int_close0>()
        if (size != 4) {
            throw Exception(
                "Size of PlainDerived_PlainBase_open0_int_close0_PlainBase_open0_int_close0 is not 4 but ${size} bytes")
        }
        let align = alignOf<PlainDerived_PlainBase_open0_int_close0_PlainBase_open0_int_close0>()
        if (align != 4) {
            throw Exception(
                "Alignment of PlainDerived_PlainBase_open0_int_close0_PlainBase_open0_int_close0 is not 4 but ${align} bytes")
        }
}

@C
public struct PlainDerived_PlainDerived {
    public let _base: PlainDerived_PlainBase_open0_int_close0_PlainBase_open0_int_close0
    public let tag: Int16
    public init(_base: PlainDerived_PlainBase_open0_int_close0_PlainBase_open0_int_close0, tag: Int16) {
        this._base = _base
        this.tag = tag
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<PlainDerived_PlainDerived>()
        if (size != 8) {
            throw Exception("Size of PlainDerived_PlainDerived is not 8 but ${size} bytes")
        }
        let align = alignOf<PlainDerived_PlainDerived>()
        if (align != 4) {
            throw Exception("Alignment of PlainDerived_PlainDerived is not 4 but ${align} bytes")
        }
}
