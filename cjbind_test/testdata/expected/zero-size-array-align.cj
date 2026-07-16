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
public struct dm_deps {
    public var count: UInt32
    public var filler: UInt32
    public let device: VArray<UInt64, $0> = unsafe { zeroValue<VArray<UInt64, $0>>() }
    public init(count: UInt32, filler: UInt32) {
        this.count = count
        this.filler = filler
    }
}

public unsafe func dm_deps_device_ptr(value: CPointer<dm_deps>): CPointer<UInt64> {
    return CPointer<UInt64>(CPointer<UInt8>(value) + 8)
}

public unsafe func dm_deps_device_view(value: CPointer<dm_deps>, count!: Int64): __CjbindArrayView<UInt64> {
    return __CjbindArrayView<UInt64>(pointer: dm_deps_device_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<dm_deps>()
        if (size != 8) {
            throw Exception("Size of dm_deps is not 8 but ${size} bytes")
        }
        let align = alignOf<dm_deps>()
        if (align != 8) {
            throw Exception("Alignment of dm_deps is not 8 but ${align} bytes")
        }
}
