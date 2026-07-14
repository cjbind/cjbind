package cjbind_ffi

public const RTE_CACHE_LINE_SIZE_RTE_CACHE_LINE_SIZE: Int64 = 64
public const RTE_LIBRTE_IP_FRAG_MAX_FRAG_RTE_LIBRTE_IP_FRAG_MAX_FRAG: Int64 = 4

//< index of last fragment *
public const IP_LAST_FRAG_IDX: _cjbind_ty_1__cjbind_ty_1 = 0

//< index of first fragment *
public const IP_FIRST_FRAG_IDX: _cjbind_ty_1__cjbind_ty_1 = 1

//< minimum number of fragments *
public const IP_MIN_FRAG_NUM: _cjbind_ty_1__cjbind_ty_1 = 2
public const IP_MAX_FRAG_NUM: _cjbind_ty_1__cjbind_ty_1 = 4

public type _cjbind_ty_1__cjbind_ty_1 = UInt32

// @internal fragmented mbuf *
@C
public struct ip_frag_ip_frag {
    //< offset into the packet *
    public let ofs: UInt16
    //< length of fragment *
    public let len: UInt16
    //< fragment mbuf *
    public let mb: CPointer<rte_mbuf_rte_mbuf>
    public func clone(): ip_frag_ip_frag {
        return this
    }
    public func toString(): String {
        var output = "ip_frag_ip_frag {"
        output += " ofs: "
        output += this.ofs.toString()
        output += ", len: "
        output += this.len.toString()
        output += ", mb: "
        output += CPointer<Unit>(this.mb).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(ofs: UInt16, len: UInt16, mb: CPointer<rte_mbuf_rte_mbuf>) {
        this.ofs = ofs
        this.len = len
        this.mb = mb
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag_ip_frag>()
        if (size != 16) {
            throw Exception("Size of ip_frag_ip_frag is not 16 but ${size} bytes")
        }
        let align = alignOf<ip_frag_ip_frag>()
        if (align != 8) {
            throw Exception("Alignment of ip_frag_ip_frag is not 8 but ${align} bytes")
        }
}

// @internal <src addr, dst_addr, id> to uniquely indetify fragmented datagram. *
@C
public struct ip_frag_key_ip_frag_key {
    //< src address, first 8 bytes used for IPv4 *
    public let src_dst: VArray<UInt64, $4>
    //< dst address *
    public let id: UInt32
    //< src/dst key length *
    public let key_len: UInt32
    public func clone(): ip_frag_key_ip_frag_key {
        return this
    }
    public func toString(): String {
        var output = "ip_frag_key_ip_frag_key {"
        output += " src_dst: "
        output += "["
        for (__cjbindDebugIndex0 in 0..4) {
            if (__cjbindDebugIndex0 != 0) {
                output += ", "
            }
            output += this.src_dst[__cjbindDebugIndex0].toString()
        }
        output += "]"
        output += ", id: "
        output += this.id.toString()
        output += ", key_len: "
        output += this.key_len.toString()
        output += " }"
        return output
    }
    public init(src_dst: VArray<UInt64, $4>, id: UInt32, key_len: UInt32) {
        this.src_dst = src_dst
        this.id = id
        this.key_len = key_len
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag_key_ip_frag_key>()
        if (size != 40) {
            throw Exception("Size of ip_frag_key_ip_frag_key is not 40 but ${size} bytes")
        }
        let align = alignOf<ip_frag_key_ip_frag_key>()
        if (align != 8) {
            throw Exception("Alignment of ip_frag_key_ip_frag_key is not 8 but ${align} bytes")
        }
}

@C
public struct ip_frag_pkt__cjbind_ty_1__cjbind_ty_1 {
    public let tqe_next: CPointer<ip_frag_pkt_ip_frag_pkt>
    public let tqe_prev: CPointer<CPointer<ip_frag_pkt_ip_frag_pkt>>
    public func clone(): ip_frag_pkt__cjbind_ty_1__cjbind_ty_1 {
        return this
    }
    public func toString(): String {
        var output = "ip_frag_pkt__cjbind_ty_1__cjbind_ty_1 {"
        output += " tqe_next: "
        output += CPointer<Unit>(this.tqe_next).toUIntNative().toString()
        output += ", tqe_prev: "
        output += CPointer<Unit>(this.tqe_prev).toUIntNative().toString()
        output += " }"
        return output
    }
    public init(tqe_next: CPointer<ip_frag_pkt_ip_frag_pkt>, tqe_prev: CPointer<CPointer<ip_frag_pkt_ip_frag_pkt>>) {
        this.tqe_next = tqe_next
        this.tqe_prev = tqe_prev
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag_pkt__cjbind_ty_1__cjbind_ty_1>()
        if (size != 16) {
            throw Exception("Size of ip_frag_pkt__cjbind_ty_1__cjbind_ty_1 is not 16 but ${size} bytes")
        }
        let align = alignOf<ip_frag_pkt__cjbind_ty_1__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of ip_frag_pkt__cjbind_ty_1__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

// @internal Fragmented packet to reassemble.
// First two entries in the frags[] array are for the last and first fragments.
@C
public struct ip_frag_pkt_ip_frag_pkt {
    let _cjbind_opaque_blob: VArray<UInt8, $192>
    public func clone(): ip_frag_pkt_ip_frag_pkt {
        return this
    }
    public func toString(): String {
        var output = "ip_frag_pkt_ip_frag_pkt {"
        output += " <opaque>"
        output += " }"
        return output
    }
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $192>>() }
    }
}

@C
public struct rte_mbuf_rte_mbuf {
    let _cjbind_empty: UInt8
    public func clone(): rte_mbuf_rte_mbuf {
        return this
    }
    public func toString(): String {
        var output = "rte_mbuf_rte_mbuf {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
