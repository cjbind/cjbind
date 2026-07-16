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
func __cjbind_bitfield_read(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): UInt64 {
    let startByte = bitOffset / 8
    let bitShift = bitOffset % 8
    let bytesNeeded = (bitWidth + bitShift + 7) / 8
    var val: UInt64 = 0
    var i: Int64 = 0
    while (i < bytesNeeded) {
        val = val | (UInt64(unsafe { ptr.read(startByte + i) }) << UInt64(i * 8))
        i++
    }
    val = val >> UInt64(bitShift)
    if (bitWidth < 64) {
        val = val & ((UInt64(1) << UInt64(bitWidth)) - 1)
    }
    return val
}

@C
func __cjbind_bitfield_write(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64, val: UInt64): Unit {
    let startByte = bitOffset / 8
    let bitShift = bitOffset % 8
    let bytesNeeded = (bitWidth + bitShift + 7) / 8
    var maskVal = val
    if (bitWidth < 64) {
        maskVal = maskVal & ((UInt64(1) << UInt64(bitWidth)) - 1)
    }
    maskVal = maskVal << UInt64(bitShift)
    var fieldMask: UInt64 = if (bitWidth + bitShift < 64) {
        ((UInt64(1) << UInt64(bitWidth)) - 1) << UInt64(bitShift)
    } else {
        !UInt64(0) << UInt64(bitShift)
    }
    var i: Int64 = 0
    while (i < bytesNeeded) {
        let byteVal = UInt8((maskVal >> UInt64(i * 8)) & 0xFF)
        let byteMask = UInt8((fieldMask >> UInt64(i * 8)) & 0xFF)
        let old = unsafe { ptr.read(startByte + i) }
        unsafe { ptr.write(startByte + i, (old & !byteMask) | (byteVal & byteMask)) }
        i++
    }
}

@C
func __cjbind_bitfield_read_signed(ptr: CPointer<UInt8>, bitOffset: Int64, bitWidth: Int64): Int64 {
    let raw = unsafe { __cjbind_bitfield_read(ptr, bitOffset, bitWidth) }
    if (bitWidth > 0 && bitWidth < 64 && (raw & (UInt64(1) << UInt64(bitWidth - 1))) != 0) {
        let extended = raw | !((UInt64(1) << UInt64(bitWidth)) - 1)
        return unsafe { __cjbind_bitfield_uint64_to_int64(extended) }
    }
    return unsafe { __cjbind_bitfield_uint64_to_int64(raw) }
}

@C
func __cjbind_bitfield_int64_to_uint64(value: Int64): UInt64 {
    var copy = value
    return unsafe { CPointer<UInt64>(CPointer<Int64>(inout copy)).read() }
}

@C
func __cjbind_bitfield_uint64_to_int64(value: UInt64): Int64 {
    var copy = value
    return unsafe { CPointer<Int64>(CPointer<UInt64>(inout copy)).read() }
}

@C
public struct rte_kni_fifo {
    //< Next position to be written*
    public var write: UInt32
    //< Next position to be read *
    public var read: UInt32
    //< Circular buffer length *
    public var len: UInt32
    //< Pointer size - for 32/64 bit OS *
    public var elem_size: UInt32
    //< The buffer contains mbuf pointers *
    public let buffer: VArray<CPointer<Unit>, $0> = unsafe { zeroValue<VArray<CPointer<Unit>, $0>>() }
    public init(write: UInt32, read: UInt32, len: UInt32, elem_size: UInt32) {
        this.write = write
        this.read = read
        this.len = len
        this.elem_size = elem_size
    }
}

public unsafe func rte_kni_fifo_buffer_ptr(value: CPointer<rte_kni_fifo>): CPointer<CPointer<Unit>> {
    return CPointer<CPointer<Unit>>(CPointer<UInt8>(value) + 16)
}

public unsafe func rte_kni_fifo_buffer_view(value: CPointer<rte_kni_fifo>, count!: Int64): __CjbindArrayView<CPointer<Unit>> {
    return __CjbindArrayView<CPointer<Unit>>(pointer: rte_kni_fifo_buffer_ptr(value), size: count)
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_kni_fifo>()
        if (size != 16) {
            throw Exception("Size of rte_kni_fifo is not 16 but ${size} bytes")
        }
        let align = alignOf<rte_kni_fifo>()
        if (align != 8) {
            throw Exception("Alignment of rte_kni_fifo is not 8 but ${align} bytes")
        }
}

@C
public struct rte_eth_link {
    //< ETH_SPEED_NUM_ *
    public var link_speed: UInt32 = unsafe { zeroValue<UInt32>() }
    var _bitfield_1: VArray<UInt16, $2> = unsafe { zeroValue<VArray<UInt16, $2>>() }
    public mut prop link_duplex: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 1, UInt64(value)) }
        }
    }
    public mut prop link_autoneg: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 1, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 1, 1, UInt64(value)) }
        }
    }
    public mut prop link_status: UInt16 {
        get() {
            var s = this._bitfield_1
            return UInt16(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 2, 1) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 2, 1, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt64, $0> = unsafe { zeroValue<VArray<UInt64, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_eth_link>()
        if (size != 8) {
            throw Exception("Size of rte_eth_link is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_eth_link>()
        if (align != 8) {
            throw Exception("Alignment of rte_eth_link is not 8 but ${align} bytes")
        }
}
