package cjbind_ffi

public const RTE_CACHE_LINE_SIZE: Int64 = 64
public const RTE_LIBRTE_IP_FRAG_MAX_FRAG: Int64 = 4

//< index of last fragment *
public const IP_LAST_FRAG_IDX: _cjbind_ty_1 = 0

//< index of first fragment *
public const IP_FIRST_FRAG_IDX: _cjbind_ty_1 = 1

//< minimum number of fragments *
public const IP_MIN_FRAG_NUM: _cjbind_ty_1 = 2
public const IP_MAX_FRAG_NUM: _cjbind_ty_1 = 4

public type _cjbind_ty_1 = UInt32

// @internal fragmented mbuf *
@C
public struct ip_frag {
    //< offset into the packet *
    public let ofs: UInt16
    //< length of fragment *
    public let len: UInt16
    //< fragment mbuf *
    public let mb: CPointer<rte_mbuf>
    public init(ofs: UInt16, len: UInt16, mb: CPointer<rte_mbuf>) {
        this.ofs = ofs
        this.len = len
        this.mb = mb
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag>()
        if (size != 16) {
            throw Exception("Size of ip_frag is not 16 but ${size} bytes")
        }
        let align = alignOf<ip_frag>()
        if (align != 8) {
            throw Exception("Alignment of ip_frag is not 8 but ${align} bytes")
        }
}

// @internal <src addr, dst_addr, id> to uniquely indetify fragmented datagram. *
@C
public struct ip_frag_key {
    //< src address, first 8 bytes used for IPv4 *
    public let src_dst: VArray<UInt64, $4>
    //< dst address *
    public let id: UInt32
    //< src/dst key length *
    public let key_len: UInt32
    public init(src_dst: VArray<UInt64, $4>, id: UInt32, key_len: UInt32) {
        this.src_dst = src_dst
        this.id = id
        this.key_len = key_len
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag_key>()
        if (size != 40) {
            throw Exception("Size of ip_frag_key is not 40 but ${size} bytes")
        }
        let align = alignOf<ip_frag_key>()
        if (align != 8) {
            throw Exception("Alignment of ip_frag_key is not 8 but ${align} bytes")
        }
}

@C
public struct ip_frag_pkt__cjbind_ty_1 {
    public let tqe_next: CPointer<ip_frag_pkt>
    public let tqe_prev: CPointer<CPointer<ip_frag_pkt>>
    public init(tqe_next: CPointer<ip_frag_pkt>, tqe_prev: CPointer<CPointer<ip_frag_pkt>>) {
        this.tqe_next = tqe_next
        this.tqe_prev = tqe_prev
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag_pkt__cjbind_ty_1>()
        if (size != 16) {
            throw Exception("Size of ip_frag_pkt__cjbind_ty_1 is not 16 but ${size} bytes")
        }
        let align = alignOf<ip_frag_pkt__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of ip_frag_pkt__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

// @internal Fragmented packet to reassemble.
// First two entries in the frags[] array are for the last and first fragments.
@C
public struct ip_frag_pkt {
    let _cjbind_opaque_blob: VArray<UInt8, $192>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $192>>() }
    }
}

//< fragment mbuf *
@C
public struct rte_mbuf {
    let _cjbind_empty: UInt8
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
