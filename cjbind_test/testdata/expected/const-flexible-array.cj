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

func __cjbind_read_Int32_from_UInt32(storage: UInt32): Int32 {
    var s = storage
    return unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_Int32_from_UInt32(storage: UInt32, val: Int32): UInt32 {
    var s = storage
    unsafe { CPointer<Int32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

@C
public struct ConstPacket {
    public var size: Int32
    public let payload: VArray<UInt16, $0> = unsafe { zeroValue<VArray<UInt16, $0>>() }
    public init(size: Int32) {
        this.size = size
    }
}

public unsafe func ConstPacket_payload_view(value: CPointer<ConstPacket>, count!: Int64): __CjbindConstArrayView<UInt16> {
    let pointer = CPointer<UInt16>(CPointer<UInt8>(value) + 4)
    return __CjbindConstArrayView<UInt16>(pointer: pointer, size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ConstPacket>()
        if (size != 4) {
            throw Exception("Size of ConstPacket is not 4 but ${size} bytes")
        }
        let align = alignOf<ConstPacket>()
        if (align != 4) {
            throw Exception("Alignment of ConstPacket is not 4 but ${align} bytes")
        }
}

@C
public struct MultiZero {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop scalar: Int32 {
        get() {
            return __cjbind_read_Int32_from_UInt32(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_Int32_from_UInt32(this._storage, value)
        }
    }
}

public unsafe func MultiZero_first_ptr(value: CPointer<MultiZero>): CPointer<Int32> {
    return CPointer<Int32>(CPointer<UInt8>(value) + 0)
}

public unsafe func MultiZero_first_view(value: CPointer<MultiZero>, count!: Int64): __CjbindArrayView<Int32> {
    return __CjbindArrayView<Int32>(pointer: MultiZero_first_ptr(value), size: count)
}

public unsafe func MultiZero_second_ptr(value: CPointer<MultiZero>): CPointer<UInt16> {
    return CPointer<UInt16>(CPointer<UInt8>(value) + 0)
}

public unsafe func MultiZero_second_view(value: CPointer<MultiZero>, count!: Int64): __CjbindArrayView<UInt16> {
    return __CjbindArrayView<UInt16>(pointer: MultiZero_second_ptr(value), size: count)
}

public unsafe func MultiZero_read_only_view(value: CPointer<MultiZero>, count!: Int64): __CjbindConstArrayView<UInt8> {
    let pointer = CPointer<UInt8>(CPointer<UInt8>(value) + 0)
    return __CjbindConstArrayView<UInt8>(pointer: pointer, size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<MultiZero>()
        if (size != 4) {
            throw Exception("Size of MultiZero is not 4 but ${size} bytes")
        }
        let align = alignOf<MultiZero>()
        if (align != 4) {
            throw Exception("Alignment of MultiZero is not 4 but ${align} bytes")
        }
}

@C
public struct FirstItems {
    public var size: Int32
    public let items: VArray<Int32, $0> = unsafe { zeroValue<VArray<Int32, $0>>() }
    public init(size: Int32) {
        this.size = size
    }
}

public unsafe func FirstItems_items_ptr(value: CPointer<FirstItems>): CPointer<Int32> {
    return CPointer<Int32>(CPointer<UInt8>(value) + 4)
}

public unsafe func FirstItems_items_view(value: CPointer<FirstItems>, count!: Int64): __CjbindArrayView<Int32> {
    return __CjbindArrayView<Int32>(pointer: FirstItems_items_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<FirstItems>()
        if (size != 4) {
            throw Exception("Size of FirstItems is not 4 but ${size} bytes")
        }
        let align = alignOf<FirstItems>()
        if (align != 4) {
            throw Exception("Alignment of FirstItems is not 4 but ${align} bytes")
        }
}

@C
public struct SecondItems {
    public var size: Int32
    public let items: VArray<Int32, $0> = unsafe { zeroValue<VArray<Int32, $0>>() }
    public init(size: Int32) {
        this.size = size
    }
}

public unsafe func SecondItems_items_ptr(value: CPointer<SecondItems>): CPointer<Int32> {
    return CPointer<Int32>(CPointer<UInt8>(value) + 4)
}

public unsafe func SecondItems_items_view(value: CPointer<SecondItems>, count!: Int64): __CjbindArrayView<Int32> {
    return __CjbindArrayView<Int32>(pointer: SecondItems_items_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<SecondItems>()
        if (size != 4) {
            throw Exception("Size of SecondItems is not 4 but ${size} bytes")
        }
        let align = alignOf<SecondItems>()
        if (align != 4) {
            throw Exception("Alignment of SecondItems is not 4 but ${align} bytes")
        }
}
