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
public struct U {
    var _storage: VArray<UInt8, $2> = unsafe { zeroValue<VArray<UInt8, $2>>() }
    public init() {}
}

public unsafe func U_d0_ptr(value: CPointer<U>): CPointer<UInt8> {
    return CPointer<UInt8>(CPointer<UInt8>(value) + 0)
}

public unsafe func U_d0_view(value: CPointer<U>, count!: Int64): __CjbindArrayView<UInt8> {
    return __CjbindArrayView<UInt8>(pointer: U_d0_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<U>()
        if (size != 2) {
            throw Exception("Size of U is not 2 but ${size} bytes")
        }
        let align = alignOf<U>()
        if (align != 1) {
            throw Exception("Alignment of U is not 1 but ${align} bytes")
        }
}
