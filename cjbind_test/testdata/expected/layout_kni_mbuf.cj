package cjbind_ffi

public const RTE_CACHE_LINE_MIN_SIZE_RTE_CACHE_LINE_MIN_SIZE: Int64 = 64
public const RTE_CACHE_LINE_SIZE_RTE_CACHE_LINE_SIZE: Int64 = 64

@C
public struct rte_kni_mbuf_rte_kni_mbuf {
    let _cjbind_opaque_blob: VArray<UInt8, $128>
    private init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $128>>() }
    }
}
