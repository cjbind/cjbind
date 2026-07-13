package cjbind_ffi

public const RTE_CACHE_LINE_SIZE_RTE_CACHE_LINE_SIZE: Int64 = 64
public const RTE_MEMPOOL_OPS_NAMESIZE_RTE_MEMPOOL_OPS_NAMESIZE: Int64 = 32
public const RTE_MEMPOOL_MAX_OPS_IDX_RTE_MEMPOOL_MAX_OPS_IDX: Int64 = 16
public const RTE_HEAP_NUM_FREELISTS_RTE_HEAP_NUM_FREELISTS: Int64 = 13

@C
public struct rte_mempool_rte_mempool {
    init() {
        throw Exception("type should not be inited")
    }
}

// Prototype for implementation specific data provisioning function.
//
// The function should provide the implementation specific memory for
// for use by the other mempool ops functions in a given mempool ops struct.
// E.g. the default ops provides an instance of the rte_ring for this purpose.
// it will most likely point to a different type of data structure, and
// will be transparent to the application programmer.
// This function should set mp->pool_data.
public type rte_mempool_alloc_t_rte_mempool_alloc_t = CFunc<(mp: CPointer<rte_mempool_rte_mempool>) -> Int32>

// Free the opaque private data pointed to by mp->pool_data pointer.
public type rte_mempool_free_t_rte_mempool_free_t = CFunc<(mp: CPointer<rte_mempool_rte_mempool>) -> Unit>

// Enqueue an object into the external pool.
public type rte_mempool_enqueue_t_rte_mempool_enqueue_t = CFunc<(mp: CPointer<rte_mempool_rte_mempool>, obj_table: CPointer<CPointer<Unit>>,
    n: UInt32) -> Int32>

// Dequeue an object from the external pool.
public type rte_mempool_dequeue_t_rte_mempool_dequeue_t = CFunc<(mp: CPointer<rte_mempool_rte_mempool>, obj_table: CPointer<CPointer<Unit>>,
    n: UInt32) -> Int32>

// Return the number of available objects in the external pool.
public type rte_mempool_get_count_rte_mempool_get_count = CFunc<(mp: CPointer<rte_mempool_rte_mempool>) -> UInt32>

// Structure defining mempool operations structure *
@C
public struct rte_mempool_ops_rte_mempool_ops {
    let _cjbind_opaque_blob: VArray<UInt8, $128>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $128>>() }
    }
}

// The rte_spinlock_t type.
@C
public struct rte_spinlock_t_rte_spinlock_t {
    //< lock status 0 = unlocked, 1 = locked *
    public let locked: Int32
    public init(locked: Int32) {
        this.locked = locked
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_spinlock_t_rte_spinlock_t>()
        if (size != 4) {
            throw Exception("Size of rte_spinlock_t_rte_spinlock_t is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_spinlock_t_rte_spinlock_t>()
        if (align != 4) {
            throw Exception("Alignment of rte_spinlock_t_rte_spinlock_t is not 4 but ${align} bytes")
        }
}

// Structure storing the table of registered ops structs, each of which contain
// the function pointers for the mempool ops functions.
// Each process has its own storage for this ops struct array so that
// the mempools can be shared across primary and secondary processes.
// The indices used to access the array are valid across processes, whereas
// any function pointers stored directly in the mempool struct would not be.
// This results in us simply having "ops_index" in the mempool struct.
@C
public struct rte_mempool_ops_table_rte_mempool_ops_table {
    let _cjbind_opaque_blob: VArray<UInt8, $2112>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $2112>>() }
    }
}

@C
public struct malloc_heap__cjbind_ty_1__cjbind_ty_1 {
    public let lh_first: CPointer<malloc_elem_malloc_elem>
    public init(lh_first: CPointer<malloc_elem_malloc_elem>) {
        this.lh_first = lh_first
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<malloc_heap__cjbind_ty_1__cjbind_ty_1>()
        if (size != 8) {
            throw Exception("Size of malloc_heap__cjbind_ty_1__cjbind_ty_1 is not 8 but ${size} bytes")
        }
        let align = alignOf<malloc_heap__cjbind_ty_1__cjbind_ty_1>()
        if (align != 8) {
            throw Exception("Alignment of malloc_heap__cjbind_ty_1__cjbind_ty_1 is not 8 but ${align} bytes")
        }
}

// Structure to hold malloc heap
@C
public struct malloc_heap_malloc_heap {
    let _cjbind_opaque_blob: VArray<UInt8, $128>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $128>>() }
    }
}

@C
public struct malloc_elem_malloc_elem {}
