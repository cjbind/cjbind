package cjbind_ffi

// A bounded view over a C flexible or zero-length array. Construction from an owning pointer and indexing stay unsafe because pointer validity and lifetime are caller contracts.
public struct __CjbindArrayView<T> where T <: CType {
    let _pointer: CPointer<T>
    let _size: Int64

    public init(pointer!: CPointer<T>, size!: Int64) {
        this._pointer = pointer
        this._size = size
        if (size < 0) {
            throw Exception("array view size cannot be negative")
        }
    }

    public prop pointer: CPointer<T> {
        get() {
            return this._pointer
        }
    }

    public prop size: Int64 {
        get() {
            return this._size
        }
    }

    public prop isEmpty: Bool {
        get() {
            return this._size == 0
        }
    }

    public unsafe operator func [](index: Int64): T {
        if (index < 0 || index >= this._size) {
            throw Exception("array view index out of bounds")
        }
        return this._pointer.read(index)
    }

    public unsafe operator func [](index: Int64, value!: T): Unit {
        if (index < 0 || index >= this._size) {
            throw Exception("array view index out of bounds")
        }
        this._pointer.write(index, value)
    }
}

public struct __CjbindConstArrayView<T> where T <: CType {
    let _pointer: CPointer<T>
    let _size: Int64

    init(pointer!: CPointer<T>, size!: Int64) {
        this._pointer = pointer
        this._size = size
        if (size < 0) {
            throw Exception("array view size cannot be negative")
        }
    }

    public prop size: Int64 {
        get() {
            return this._size
        }
    }

    public prop isEmpty: Bool {
        get() {
            return this._size == 0
        }
    }

    public unsafe operator func [](index: Int64): T {
        if (index < 0 || index >= this._size) {
            throw Exception("array view index out of bounds")
        }
        return this._pointer.read(index)
    }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_1 {
    public let __empty_value1: bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1
    public let value1: VArray<UInt8, $0> = unsafe { zeroValue<VArray<UInt8, $0>>() }
    public init(__empty_value1: bpf_array__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1) {
        this.__empty_value1 = __empty_value1
    }
}

public unsafe func bpf_array__cjbind_ty_1__cjbind_ty_1_value1_ptr(value: CPointer<bpf_array__cjbind_ty_1__cjbind_ty_1>): CPointer<UInt8> {
    return CPointer<UInt8>(CPointer<UInt8>(value) + 0)
}

public unsafe func bpf_array__cjbind_ty_1__cjbind_ty_1_value1_view(
    value: CPointer<bpf_array__cjbind_ty_1__cjbind_ty_1>, count!: Int64): __CjbindArrayView<UInt8> {
    return __CjbindArrayView<UInt8>(pointer: bpf_array__cjbind_ty_1__cjbind_ty_1_value1_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_1>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1 {}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1__cjbind_ty_2 {
    public let __empty_value2: bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1
    public let value2: VArray<UInt8, $0> = unsafe { zeroValue<VArray<UInt8, $0>>() }
    public init(__empty_value2: bpf_array__cjbind_ty_1__cjbind_ty_2__cjbind_ty_1) {
        this.__empty_value2 = __empty_value2
    }
}

public unsafe func bpf_array__cjbind_ty_1__cjbind_ty_2_value2_ptr(value: CPointer<bpf_array__cjbind_ty_1__cjbind_ty_2>): CPointer<UInt8> {
    return CPointer<UInt8>(CPointer<UInt8>(value) + 0)
}

public unsafe func bpf_array__cjbind_ty_1__cjbind_ty_2_value2_view(
    value: CPointer<bpf_array__cjbind_ty_1__cjbind_ty_2>, count!: Int64): __CjbindArrayView<UInt8> {
    return __CjbindArrayView<UInt8>(pointer: bpf_array__cjbind_ty_1__cjbind_ty_2_value2_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1__cjbind_ty_2>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1__cjbind_ty_2 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1__cjbind_ty_2>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1__cjbind_ty_2 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array__cjbind_ty_1 {
    var _storage: VArray<UInt8, $0> = unsafe { zeroValue<VArray<UInt8, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array__cjbind_ty_1>()
        if (size != 0) {
            throw Exception("Size of bpf_array__cjbind_ty_1 is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array__cjbind_ty_1>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array__cjbind_ty_1 is not 1 but ${align} bytes")
        }
}

@C
public struct bpf_array {
    public let __cjbind_anon_1: bpf_array__cjbind_ty_1
    public init(__cjbind_anon_1: bpf_array__cjbind_ty_1) {
        this.__cjbind_anon_1 = __cjbind_anon_1
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<bpf_array>()
        if (size != 0) {
            throw Exception("Size of bpf_array is not 0 but ${size} bytes")
        }
        let align = alignOf<bpf_array>()
        if (align != 1) {
            throw Exception("Alignment of bpf_array is not 1 but ${align} bytes")
        }
}
