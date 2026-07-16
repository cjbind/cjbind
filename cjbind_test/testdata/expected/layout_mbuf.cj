package cjbind_ffi

func __cjbind_read_UInt16_from_UInt16(storage: UInt16): UInt16 {
    var s = storage
    return unsafe { CPointer<UInt16>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt16_from_UInt16(storage: UInt16, val: UInt16): UInt16 {
    var s = storage
    unsafe { CPointer<UInt16>(CPointer<UInt8>(inout s)).write(val) }
    return s
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

func __cjbind_read_UInt32_from_UInt32(storage: UInt32): UInt32 {
    var s = storage
    return unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt32_from_UInt32(storage: UInt32, val: UInt32): UInt32 {
    var s = storage
    unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_UInt32_from_VArray_UInt32__2_(storage: VArray<UInt32, $2>): UInt32 {
    var s = storage
    return unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt32_from_VArray_UInt32__2_(storage: VArray<UInt32, $2>, val: UInt32): VArray<UInt32, $2> {
    var s = storage
    unsafe { CPointer<UInt32>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_CPointer_Unit__from_UInt64(storage: UInt64): CPointer<Unit> {
    var s = storage
    return unsafe { CPointer<CPointer<Unit>>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_CPointer_Unit__from_UInt64(storage: UInt64, val: CPointer<Unit>): UInt64 {
    var s = storage
    unsafe { CPointer<CPointer<Unit>>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_UInt64_from_UInt64(storage: UInt64): UInt64 {
    var s = storage
    return unsafe { CPointer<UInt64>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_UInt64_from_UInt64(storage: UInt64, val: UInt64): UInt64 {
    var s = storage
    unsafe { CPointer<UInt64>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

public const RTE_CACHE_LINE_MIN_SIZE: Int64 = 64
public const RTE_CACHE_LINE_SIZE: Int64 = 64

public type phys_addr_t = UInt64

public type MARKER = VArray<CPointer<Unit>, $0>

public type MARKER8 = VArray<UInt8, $0>

public type MARKER64 = VArray<UInt64, $0>

// The atomic counter structure.
@C
public struct rte_atomic16_t {
    //< An internal counter value. *
    public var cnt: Int16
    public init(cnt: Int16) {
        this.cnt = cnt
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_atomic16_t>()
        if (size != 2) {
            throw Exception("Size of rte_atomic16_t is not 2 but ${size} bytes")
        }
        let align = alignOf<rte_atomic16_t>()
        if (align != 2) {
            throw Exception("Alignment of rte_atomic16_t is not 2 but ${align} bytes")
        }
}

// 16-bit Reference counter.
// It should only be accessed using the following functions:
// rte_mbuf_refcnt_update(), rte_mbuf_refcnt_read(), and
// rte_mbuf_refcnt_set(). The functionality of these functions (atomic,
// or non-atomic) is controlled by the CONFIG_RTE_MBUF_REFCNT_ATOMIC
// config option.
@C
public struct rte_mbuf__cjbind_ty_1 {
    var _storage: UInt16 = unsafe { zeroValue<UInt16>() }
    public init() {}
    public mut prop refcnt: UInt16 {
        get() {
            return __cjbind_read_UInt16_from_UInt16(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt16_from_UInt16(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_1>()
        if (size != 2) {
            throw Exception("Size of rte_mbuf__cjbind_ty_1 is not 2 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_1>()
        if (align != 2) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_2__cjbind_ty_1 {
    var _bitfield_1: UInt32 = unsafe { zeroValue<UInt32>() }
    public mut prop l2_type: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 4, UInt64(value)) }
        }
    }
    public mut prop l3_type: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 4, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 4, 4, UInt64(value)) }
        }
    }
    public mut prop l4_type: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 8, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 8, 4, UInt64(value)) }
        }
    }
    public mut prop tun_type: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 12, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 12, 4, UInt64(value)) }
        }
    }
    public mut prop inner_l2_type: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 16, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 16, 4, UInt64(value)) }
        }
    }
    public mut prop inner_l3_type: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 20, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 20, 4, UInt64(value)) }
        }
    }
    public mut prop inner_l4_type: UInt32 {
        get() {
            var s = this._bitfield_1
            return UInt32(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 24, 4) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 24, 4, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt32, $0> = unsafe { zeroValue<VArray<UInt32, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_2__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of rte_mbuf__cjbind_ty_2__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_2__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_2__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_2 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop packet_type: UInt32 {
        get() {
            return __cjbind_read_UInt32_from_UInt32(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_2>()
        if (size != 4) {
            throw Exception("Size of rte_mbuf__cjbind_ty_2 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_2>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_2 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    public var hash: UInt16
    public var id: UInt16
    public init(hash: UInt16, id: UInt16) {
        this.hash = hash
        this.id = id
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception(
                "Size of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (align != 2) {
            throw Exception(
                "Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public mut prop lo: UInt32 {
        get() {
            return __cjbind_read_UInt32_from_UInt32(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_1 {
    public let __cjbind_anon_1: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1
    public var hi: UInt32
    public init(__cjbind_anon_1: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1, hi: UInt32) {
        this.__cjbind_anon_1 = __cjbind_anon_1
        this.hi = hi
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_3__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_2 {
    public var lo: UInt32
    public var hi: UInt32
    public init(lo: UInt32, hi: UInt32) {
        this.lo = lo
        this.hi = hi
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_2>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_3__cjbind_ty_2 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_2>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_2 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3 {
    var _storage: VArray<UInt32, $2> = unsafe { zeroValue<VArray<UInt32, $2>>() }
    public init() {}
    public mut prop rss: UInt32 {
        get() {
            return __cjbind_read_UInt32_from_VArray_UInt32__2_(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt32_from_VArray_UInt32__2_(this._storage, value)
        }
    }
    public mut prop usr: UInt32 {
        get() {
            return __cjbind_read_UInt32_from_VArray_UInt32__2_(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt32_from_VArray_UInt32__2_(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_3 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_3 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_4 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    public init() {}
    public mut prop userdata: CPointer<Unit> {
        get() {
            return __cjbind_read_CPointer_Unit__from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_CPointer_Unit__from_UInt64(this._storage, value)
        }
    }
    public mut prop udata64: UInt64 {
        get() {
            return __cjbind_read_UInt64_from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt64_from_UInt64(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_4>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_4 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_4>()
        if (align != 8) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_4 is not 8 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_5__cjbind_ty_1 {
    var _bitfield_1: UInt64 = unsafe { zeroValue<UInt64>() }
    public mut prop l2_len: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 0, 7) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 0, 7, UInt64(value)) }
        }
    }
    public mut prop l3_len: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 7, 9) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 7, 9, UInt64(value)) }
        }
    }
    public mut prop l4_len: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 16, 8) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 16, 8, UInt64(value)) }
        }
    }
    public mut prop tso_segsz: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 24, 16) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 24, 16, UInt64(value)) }
        }
    }
    public mut prop outer_l3_len: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 40, 9) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 40, 9, UInt64(value)) }
        }
    }
    public mut prop outer_l2_len: UInt64 {
        get() {
            var s = this._bitfield_1
            return UInt64(unsafe { __cjbind_bitfield_read(CPointer<UInt8>(inout s), 49, 7) })
        }
        set(value) {
            unsafe { __cjbind_bitfield_write(CPointer<UInt8>(inout this._bitfield_1), 49, 7, UInt64(value)) }
        }
    }
    let _cjbind_bitfield_alignment_marker: VArray<UInt64, $0> = unsafe { zeroValue<VArray<UInt64, $0>>() }
    public init() {}
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_5__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_5__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_5__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_5__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_5 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    public init() {}
    public mut prop tx_offload: UInt64 {
        get() {
            return __cjbind_read_UInt64_from_UInt64(this._storage)
        }
        set(value) {
            this._storage = __cjbind_write_UInt64_from_UInt64(this._storage, value)
        }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_5>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_5 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_5>()
        if (align != 8) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_5 is not 8 but ${align} bytes")
        }
}

// The generic rte_mbuf, containing a packet mbuf.
@C
public struct rte_mbuf {
    let _cjbind_opaque_blob: VArray<UInt8, $128>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $128>>() }
    }
}

//< Pool from which mbuf was allocated. *
@C
public struct rte_mempool {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
