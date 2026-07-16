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
public struct rte_ring_prod {
    public var watermark: UInt32
    public init(watermark: UInt32) {
        this.watermark = watermark
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ring_prod>()
        if (size != 4) {
            throw Exception("Size of rte_ring_prod is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ring_prod>()
        if (align != 4) {
            throw Exception("Alignment of rte_ring_prod is not 4 but ${align} bytes")
        }
}

@C
public struct rte_ring_cons {
    public var sc_dequeue: UInt32
    public init(sc_dequeue: UInt32) {
        this.sc_dequeue = sc_dequeue
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ring_cons>()
        if (size != 4) {
            throw Exception("Size of rte_ring_cons is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ring_cons>()
        if (align != 4) {
            throw Exception("Alignment of rte_ring_cons is not 4 but ${align} bytes")
        }
}

@C
public struct rte_ring {
    public var memzone: CPointer<rte_memzone>
    public let prod: rte_ring_prod
    public let cons: rte_ring_cons
    public let ring: VArray<CPointer<Unit>, $0> = unsafe { zeroValue<VArray<CPointer<Unit>, $0>>() }
    public init(memzone: CPointer<rte_memzone>, prod: rte_ring_prod, cons: rte_ring_cons) {
        this.memzone = memzone
        this.prod = prod
        this.cons = cons
    }
}

public unsafe func rte_ring_ring_ptr(value: CPointer<rte_ring>): CPointer<CPointer<Unit>> {
    return CPointer<CPointer<Unit>>(CPointer<UInt8>(value) + 16)
}

public unsafe func rte_ring_ring_view(value: CPointer<rte_ring>, count!: Int64): __CjbindArrayView<CPointer<Unit>> {
    return __CjbindArrayView<CPointer<Unit>>(pointer: rte_ring_ring_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ring>()
        if (size != 16) {
            throw Exception("Size of rte_ring is not 16 but ${size} bytes")
        }
        let align = alignOf<rte_ring>()
        if (align != 8) {
            throw Exception("Alignment of rte_ring is not 8 but ${align} bytes")
        }
}

@C
public struct rte_memzone {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
