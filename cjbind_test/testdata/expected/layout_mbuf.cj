package cjbind_ffi

func __cjbind_read_rte_atomic16_t_rte_atomic16_t_from_UInt16(storage: UInt16): rte_atomic16_t_rte_atomic16_t {
    var s = storage
    return unsafe { CPointer<rte_atomic16_t_rte_atomic16_t>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_atomic16_t_rte_atomic16_t_from_UInt16(storage: UInt16, val: rte_atomic16_t_rte_atomic16_t): UInt16 {
    var s = storage
    unsafe { CPointer<rte_atomic16_t_rte_atomic16_t>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

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
        return Int64(raw | !((UInt64(1) << UInt64(bitWidth)) - 1))
    }
    return Int64(raw)
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

func __cjbind_read_rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32): rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1_from_UInt32(storage: UInt32,
    val: rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1): UInt32 {
    var s = storage
    unsafe { CPointer<rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(
    storage: UInt32): rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(
        CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(
    storage: UInt32, val: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): UInt32 {
    var s = storage
    unsafe { CPointer<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>(
        CPointer<UInt8>(inout s)).write(val) }
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

func __cjbind_read_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt32__2_(storage: VArray<UInt32, $2>): rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt32__2_(storage: VArray<UInt32, $2>,
    val: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1): VArray<UInt32, $2> {
    var s = storage
    unsafe { CPointer<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

func __cjbind_read_rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt32__2_(storage: VArray<UInt32, $2>): rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2 {
    var s = storage
    return unsafe { CPointer<rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt32__2_(storage: VArray<UInt32, $2>,
    val: rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2): VArray<UInt32, $2> {
    var s = storage
    unsafe { CPointer<rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2>(CPointer<UInt8>(inout s)).write(val) }
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

func __cjbind_read_rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1_from_UInt64(storage: UInt64): rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1 {
    var s = storage
    return unsafe { CPointer<rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).read() }
}

func __cjbind_write_rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1_from_UInt64(storage: UInt64,
    val: rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1): UInt64 {
    var s = storage
    unsafe { CPointer<rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1>(CPointer<UInt8>(inout s)).write(val) }
    return s
}

public const RTE_CACHE_LINE_MIN_SIZE_RTE_CACHE_LINE_MIN_SIZE: Int64 = 64
public const RTE_CACHE_LINE_SIZE_RTE_CACHE_LINE_SIZE: Int64 = 64

public type phys_addr_t_phys_addr_t = UInt64

public type MARKER_MARKER = CPointer<CPointer<Unit>>

public type MARKER8_MARKER8 = CPointer<UInt8>

public type MARKER64_MARKER64 = CPointer<UInt64>

// The atomic counter structure.
@C
public struct rte_atomic16_t_rte_atomic16_t {
    //< An internal counter value. *
    public let cnt: Int16
    public func clone(): rte_atomic16_t_rte_atomic16_t {
        return this
    }
    public func toString(): String {
        var output = "rte_atomic16_t_rte_atomic16_t {"
        output += " cnt: "
        output += this.cnt.toString()
        output += " }"
        return output
    }
    public init(cnt: Int16) {
        this.cnt = cnt
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_atomic16_t_rte_atomic16_t>()
        if (size != 2) {
            throw Exception("Size of rte_atomic16_t_rte_atomic16_t is not 2 but ${size} bytes")
        }
        let align = alignOf<rte_atomic16_t_rte_atomic16_t>()
        if (align != 2) {
            throw Exception("Alignment of rte_atomic16_t_rte_atomic16_t is not 2 but ${align} bytes")
        }
}

// 16-bit Reference counter.
// It should only be accessed using the following functions:
// rte_mbuf_refcnt_update(), rte_mbuf_refcnt_read(), and
// rte_mbuf_refcnt_set(). The functionality of these functions (atomic,
// or non-atomic) is controlled by the CONFIG_RTE_MBUF_REFCNT_ATOMIC
// config option.
@C
public struct rte_mbuf__cjbind_ty_1__cjbind_ty_1 {
    var _storage: UInt16 = unsafe { zeroValue<UInt16>() }
    public init() {}
    public func refcnt_atomic(): rte_atomic16_t_rte_atomic16_t {
        return __cjbind_read_rte_atomic16_t_rte_atomic16_t_from_UInt16(this._storage)
    }
    public mut func refcnt_atomic(val!: rte_atomic16_t_rte_atomic16_t): Unit {
        this._storage = __cjbind_write_rte_atomic16_t_rte_atomic16_t_from_UInt16(this._storage, val)
    }
    public func refcnt(): UInt16 {
        return __cjbind_read_UInt16_from_UInt16(this._storage)
    }
    public mut func refcnt(val!: UInt16): Unit {
        this._storage = __cjbind_write_UInt16_from_UInt16(this._storage, val)
    }
    public func clone(): rte_mbuf__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_1__cjbind_ty_1>()
        if (size != 2) {
            throw Exception("Size of rte_mbuf__cjbind_ty_1__cjbind_ty_1 is not 2 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_1__cjbind_ty_1>()
        if (align != 2) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_1__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 {
    var _bitfield_1: VArray<UInt8, $4> = VArray<UInt8, $4>(repeat: 0)
    public func l2_type(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 0, 4) })
    }
    public mut func l2_type(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 4, UInt64(val)) }
    }
    public func l3_type(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 4, 4) })
    }
    public mut func l3_type(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 4, 4, UInt64(val)) }
    }
    public func l4_type(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 8, 4) })
    }
    public mut func l4_type(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 8, 4, UInt64(val)) }
    }
    public func tun_type(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 12, 4) })
    }
    public mut func tun_type(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 12, 4, UInt64(val)) }
    }
    public func inner_l2_type(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 16, 4) })
    }
    public mut func inner_l2_type(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 16, 4, UInt64(val)) }
    }
    public func inner_l3_type(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 20, 4) })
    }
    public mut func inner_l3_type(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 20, 4, UInt64(val)) }
    }
    public func inner_l4_type(): UInt32 {
        var s = this._bitfield_1
        return UInt32(unsafe { __cjbind_bitfield_read(inout s, 24, 4) })
    }
    public mut func inner_l4_type(val!: UInt32): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 24, 4, UInt64(val)) }
    }
    public init() {}
    public func clone(): rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 {"
        output += " l2_type: "
        output += this.l2_type().toString()
        output += ", l3_type: "
        output += this.l3_type().toString()
        output += ", l4_type: "
        output += this.l4_type().toString()
        output += ", tun_type: "
        output += this.tun_type().toString()
        output += ", inner_l2_type: "
        output += this.inner_l2_type().toString()
        output += ", inner_l3_type: "
        output += this.inner_l3_type().toString()
        output += ", inner_l4_type: "
        output += this.inner_l4_type().toString()
        output += " }"
        return output
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception("Size of rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_2__cjbind_ty_2 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func packet_type(): UInt32 {
        return __cjbind_read_UInt32_from_UInt32(this._storage)
    }
    public mut func packet_type(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, val)
    }
    public func __cjbind_anon_1(): rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage)
    }
    public mut func __cjbind_anon_1(val!: rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_rte_mbuf__cjbind_ty_2__cjbind_ty_1__cjbind_ty_1_from_UInt32(this._storage, val)
    }
    public func clone(): rte_mbuf__cjbind_ty_2__cjbind_ty_2 {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_2__cjbind_ty_2>()
        if (size != 4) {
            throw Exception("Size of rte_mbuf__cjbind_ty_2__cjbind_ty_2 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_2__cjbind_ty_2>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_2__cjbind_ty_2 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    public let hash: UInt16
    public let id: UInt16
    public func clone(): rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {"
        output += " hash: "
        output += this.hash.toString()
        output += ", id: "
        output += this.id.toString()
        output += " }"
        return output
    }
    public init(hash: UInt16, id: UInt16) {
        this.hash = hash
        this.id = id
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (size != 4) {
            throw Exception(
                "Size of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1>()
        if (align != 2) {
            throw Exception(
                "Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 2 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
    var _storage: UInt32 = unsafe { zeroValue<UInt32>() }
    public init() {}
    public func __cjbind_anon_1(): rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(
            this._storage)
    }
    public mut func __cjbind_anon_1(val!: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1_from_UInt32(
            this._storage, val)
    }
    public func lo(): UInt32 {
        return __cjbind_read_UInt32_from_UInt32(this._storage)
    }
    public mut func lo(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_UInt32(this._storage, val)
    }
    public func clone(): rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 {
        return this
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
        if (align != 4) {
            throw Exception(
                "Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 {
    public let __cjbind_anon_1: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1
    public let hi: UInt32
    public func clone(): rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public init(__cjbind_anon_1: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1__cjbind_ty_1, hi: UInt32) {
        this.__cjbind_anon_1 = __cjbind_anon_1
        this.hi = hi
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2 {
    public let lo: UInt32
    public let hi: UInt32
    public func clone(): rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2 {
        return this
    }
    public func toString(): String {
        var output = "rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2 {"
        output += " lo: "
        output += this.lo.toString()
        output += ", hi: "
        output += this.hi.toString()
        output += " }"
        return output
    }
    public init(lo: UInt32, hi: UInt32) {
        this.lo = lo
        this.hi = hi
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_3__cjbind_ty_3 {
    var _storage: VArray<UInt32, $2> = unsafe { zeroValue<VArray<UInt32, $2>>() }
    public init() {}
    public func rss(): UInt32 {
        return __cjbind_read_UInt32_from_VArray_UInt32__2_(this._storage)
    }
    public mut func rss(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_VArray_UInt32__2_(this._storage, val)
    }
    public func fdir(): rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt32__2_(this._storage)
    }
    public mut func fdir(val!: rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_rte_mbuf__cjbind_ty_3__cjbind_ty_1__cjbind_ty_1_from_VArray_UInt32__2_(
            this._storage, val)
    }
    public func sched(): rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2 {
        return __cjbind_read_rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt32__2_(this._storage)
    }
    public mut func sched(val!: rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2): Unit {
        this._storage = __cjbind_write_rte_mbuf__cjbind_ty_3__cjbind_ty_2__cjbind_ty_2_from_VArray_UInt32__2_(
            this._storage, val)
    }
    public func usr(): UInt32 {
        return __cjbind_read_UInt32_from_VArray_UInt32__2_(this._storage)
    }
    public mut func usr(val!: UInt32): Unit {
        this._storage = __cjbind_write_UInt32_from_VArray_UInt32__2_(this._storage, val)
    }
    public func clone(): rte_mbuf__cjbind_ty_3__cjbind_ty_3 {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_3__cjbind_ty_3>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_3__cjbind_ty_3 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_3__cjbind_ty_3>()
        if (align != 4) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_3__cjbind_ty_3 is not 4 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_4__cjbind_ty_4 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    public init() {}
    public func userdata(): CPointer<Unit> {
        return __cjbind_read_CPointer_Unit__from_UInt64(this._storage)
    }
    public mut func userdata(val!: CPointer<Unit>): Unit {
        this._storage = __cjbind_write_CPointer_Unit__from_UInt64(this._storage, val)
    }
    public func udata64(): UInt64 {
        return __cjbind_read_UInt64_from_UInt64(this._storage)
    }
    public mut func udata64(val!: UInt64): Unit {
        this._storage = __cjbind_write_UInt64_from_UInt64(this._storage, val)
    }
    public func clone(): rte_mbuf__cjbind_ty_4__cjbind_ty_4 {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_4__cjbind_ty_4>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_4__cjbind_ty_4 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_4__cjbind_ty_4>()
        if (align != 8) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_4__cjbind_ty_4 is not 8 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1 {
    var _bitfield_1: VArray<UInt8, $7> = VArray<UInt8, $7>(repeat: 0)
    public func l2_len(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 0, 7) })
    }
    public mut func l2_len(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 0, 7, UInt64(val)) }
    }
    public func l3_len(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 7, 9) })
    }
    public mut func l3_len(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 7, 9, UInt64(val)) }
    }
    public func l4_len(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 16, 8) })
    }
    public mut func l4_len(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 16, 8, UInt64(val)) }
    }
    public func tso_segsz(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 24, 16) })
    }
    public mut func tso_segsz(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 24, 16, UInt64(val)) }
    }
    public func outer_l3_len(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 40, 9) })
    }
    public mut func outer_l3_len(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 40, 9, UInt64(val)) }
    }
    public func outer_l2_len(): UInt64 {
        var s = this._bitfield_1
        return UInt64(unsafe { __cjbind_bitfield_read(inout s, 49, 7) })
    }
    public mut func outer_l2_len(val!: UInt64): Unit {
        unsafe { __cjbind_bitfield_write(inout this._bitfield_1, 49, 7, UInt64(val)) }
    }
    public init() {}
    public func clone(): rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1 {"
        output += " l2_len: "
        output += this.l2_len().toString()
        output += ", l3_len: "
        output += this.l3_len().toString()
        output += ", l4_len: "
        output += this.l4_len().toString()
        output += ", tso_segsz: "
        output += this.tso_segsz().toString()
        output += ", outer_l3_len: "
        output += this.outer_l3_len().toString()
        output += ", outer_l2_len: "
        output += this.outer_l2_len().toString()
        output += " }"
        return output
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

@C
public struct rte_mbuf__cjbind_ty_5__cjbind_ty_5 {
    var _storage: UInt64 = unsafe { zeroValue<UInt64>() }
    public init() {}
    public func tx_offload(): UInt64 {
        return __cjbind_read_UInt64_from_UInt64(this._storage)
    }
    public mut func tx_offload(val!: UInt64): Unit {
        this._storage = __cjbind_write_UInt64_from_UInt64(this._storage, val)
    }
    public func __cjbind_anon_1(): rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1 {
        return __cjbind_read_rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1_from_UInt64(this._storage)
    }
    public mut func __cjbind_anon_1(val!: rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1): Unit {
        this._storage = __cjbind_write_rte_mbuf__cjbind_ty_5__cjbind_ty_1__cjbind_ty_1_from_UInt64(this._storage, val)
    }
    public func clone(): rte_mbuf__cjbind_ty_5__cjbind_ty_5 {
        return this
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_mbuf__cjbind_ty_5__cjbind_ty_5>()
        if (size != 8) {
            throw Exception("Size of rte_mbuf__cjbind_ty_5__cjbind_ty_5 is not 8 but ${size} bytes")
        }
        let align = alignOf<rte_mbuf__cjbind_ty_5__cjbind_ty_5>()
        if (align != 8) {
            throw Exception("Alignment of rte_mbuf__cjbind_ty_5__cjbind_ty_5 is not 8 but ${align} bytes")
        }
}

// The generic rte_mbuf, containing a packet mbuf.
@C
public struct rte_mbuf_rte_mbuf {
    let _cjbind_opaque_blob: VArray<UInt8, $128>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $128>>() }
    }
}

@C
public struct rte_mempool_rte_mempool {
    let _cjbind_empty: UInt8
    public func clone(): rte_mempool_rte_mempool {
        return this
    }
    public func toString(): String {
        var output = "rte_mempool_rte_mempool {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
