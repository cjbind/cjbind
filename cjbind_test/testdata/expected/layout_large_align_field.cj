package cjbind_ffi

public const RTE_CACHE_LINE_SIZE_RTE_CACHE_LINE_SIZE: Int64 = 64
public const RTE_LIBRTE_IP_FRAG_MAX_FRAG_RTE_LIBRTE_IP_FRAG_MAX_FRAG: Int64 = 4

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
public struct ip_frag_ip_frag {
    //< offset into the packet *
    public let ofs: UInt16
    //< length of fragment *
    public let len: UInt16
    //< fragment mbuf *
    public let mb: CPointer<rte_mbuf_rte_mbuf>
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
public struct ip_frag_pkt__cjbind_ty_1 {
    public let tqe_next: CPointer<ip_frag_pkt_ip_frag_pkt>
    public let tqe_prev: CPointer<CPointer<ip_frag_pkt_ip_frag_pkt>>
    public init(tqe_next: CPointer<ip_frag_pkt_ip_frag_pkt>, tqe_prev: CPointer<CPointer<ip_frag_pkt_ip_frag_pkt>>) {
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
public struct ip_frag_pkt_ip_frag_pkt {
    //< LRU list *
    public let lru: ip_frag_pkt__cjbind_ty_1
    public let __cjbind_anon_1: ip_frag_pkt__cjbind_ty_1
    //< fragmentation key *
    public let key: ip_frag_key_ip_frag_key
    //< creation timestamp *
    public let start: UInt64
    //< expected reassembled size *
    public let total_size: UInt32
    //< size of fragments received *
    public let frag_size: UInt32
    //< index of next entry to fill *
    public let last_idx: UInt32
    //< fragments *
    public let frags: VArray<ip_frag_ip_frag, $4>
    public init(lru: ip_frag_pkt__cjbind_ty_1, __cjbind_anon_1: ip_frag_pkt__cjbind_ty_1, key: ip_frag_key_ip_frag_key,
        start: UInt64, total_size: UInt32, frag_size: UInt32, last_idx: UInt32, frags: VArray<ip_frag_ip_frag, $4>) {
        this.lru = lru
        this.__cjbind_anon_1 = __cjbind_anon_1
        this.key = key
        this.start = start
        this.total_size = total_size
        this.frag_size = frag_size
        this.last_idx = last_idx
        this.frags = frags
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag_pkt_ip_frag_pkt>()
        if (size != 192) {
            throw Exception("Size of ip_frag_pkt_ip_frag_pkt is not 192 but ${size} bytes")
        }
        let align = alignOf<ip_frag_pkt_ip_frag_pkt>()
        if (align != 64) {
            throw Exception("Alignment of ip_frag_pkt_ip_frag_pkt is not 64 but ${align} bytes")
        }
}

@C
public struct ip_pkt_list_ip_pkt_list {
    public let tqh_first: CPointer<ip_frag_pkt_ip_frag_pkt>
    public let tqh_last: CPointer<CPointer<ip_frag_pkt_ip_frag_pkt>>
    public init(tqh_first: CPointer<ip_frag_pkt_ip_frag_pkt>, tqh_last: CPointer<CPointer<ip_frag_pkt_ip_frag_pkt>>) {
        this.tqh_first = tqh_first
        this.tqh_last = tqh_last
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_pkt_list_ip_pkt_list>()
        if (size != 16) {
            throw Exception("Size of ip_pkt_list_ip_pkt_list is not 16 but ${size} bytes")
        }
        let align = alignOf<ip_pkt_list_ip_pkt_list>()
        if (align != 8) {
            throw Exception("Alignment of ip_pkt_list_ip_pkt_list is not 8 but ${align} bytes")
        }
}

// fragmentation table statistics *
@C
public struct ip_frag_tbl_stat_ip_frag_tbl_stat {
    //< total # of find/insert attempts. *
    public let find_num: UInt64
    //< # of add ops. *
    public let add_num: UInt64
    //< # of del ops. *
    public let del_num: UInt64
    //< # of reuse (del/add) ops. *
    public let reuse_num: UInt64
    //< total # of add failures. *
    public let fail_total: UInt64
    //< # of 'no space' add failures. *
    public let fail_nospace: UInt64
    public init(find_num: UInt64, add_num: UInt64, del_num: UInt64, reuse_num: UInt64, fail_total: UInt64,
        fail_nospace: UInt64) {
        this.find_num = find_num
        this.add_num = add_num
        this.del_num = del_num
        this.reuse_num = reuse_num
        this.fail_total = fail_total
        this.fail_nospace = fail_nospace
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ip_frag_tbl_stat_ip_frag_tbl_stat>()
        if (size != 64) {
            throw Exception("Size of ip_frag_tbl_stat_ip_frag_tbl_stat is not 64 but ${size} bytes")
        }
        let align = alignOf<ip_frag_tbl_stat_ip_frag_tbl_stat>()
        if (align != 64) {
            throw Exception("Alignment of ip_frag_tbl_stat_ip_frag_tbl_stat is not 64 but ${align} bytes")
        }
}

// fragmentation table *
@C
public struct rte_ip_frag_tbl_rte_ip_frag_tbl {
    //< ttl for table entries. *
    public let max_cycles: UInt64
    //< hash value mask. *
    public let entry_mask: UInt32
    //< max entries allowed. *
    public let max_entries: UInt32
    //< entries in use. *
    public let use_entries: UInt32
    //< hash assocaitivity. *
    public let bucket_entries: UInt32
    //< total size of the table. *
    public let nb_entries: UInt32
    //< num of associativity lines. *
    public let nb_buckets: UInt32
    //< last used entry. *
    public let last: CPointer<ip_frag_pkt_ip_frag_pkt>
    //< LRU list for table entries. *
    public let lru: ip_pkt_list_ip_pkt_list
    //< statistics counters. *
    public let stat: ip_frag_tbl_stat_ip_frag_tbl_stat
    //< hash table. *
    public let pkt: CPointer<ip_frag_pkt_ip_frag_pkt>
    public init(max_cycles: UInt64, entry_mask: UInt32, max_entries: UInt32, use_entries: UInt32,
        bucket_entries: UInt32, nb_entries: UInt32, nb_buckets: UInt32, last: CPointer<ip_frag_pkt_ip_frag_pkt>,
        lru: ip_pkt_list_ip_pkt_list, stat: ip_frag_tbl_stat_ip_frag_tbl_stat, pkt: CPointer<ip_frag_pkt_ip_frag_pkt>) {
        this.max_cycles = max_cycles
        this.entry_mask = entry_mask
        this.max_entries = max_entries
        this.use_entries = use_entries
        this.bucket_entries = bucket_entries
        this.nb_entries = nb_entries
        this.nb_buckets = nb_buckets
        this.last = last
        this.lru = lru
        this.stat = stat
        this.pkt = pkt
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ip_frag_tbl_rte_ip_frag_tbl>()
        if (size != 128) {
            throw Exception("Size of rte_ip_frag_tbl_rte_ip_frag_tbl is not 128 but ${size} bytes")
        }
        let align = alignOf<rte_ip_frag_tbl_rte_ip_frag_tbl>()
        if (align != 64) {
            throw Exception("Alignment of rte_ip_frag_tbl_rte_ip_frag_tbl is not 64 but ${align} bytes")
        }
}

//< fragment mbuf *
@C
public struct rte_mbuf_rte_mbuf {}