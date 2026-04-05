package cjbind_ffi

@C
public struct rte_ring_prod_prod {
    public let watermark: UInt32
    public init(watermark: UInt32) {
        this.watermark = watermark
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ring_prod_prod>()
        if (size != 4) {
            throw Exception("Size of rte_ring_prod_prod is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ring_prod_prod>()
        if (align != 4) {
            throw Exception("Alignment of rte_ring_prod_prod is not 4 but ${align} bytes")
        }
}

@C
public struct rte_ring_cons_cons {
    public let sc_dequeue: UInt32
    public init(sc_dequeue: UInt32) {
        this.sc_dequeue = sc_dequeue
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ring_cons_cons>()
        if (size != 4) {
            throw Exception("Size of rte_ring_cons_cons is not 4 but ${size} bytes")
        }
        let align = alignOf<rte_ring_cons_cons>()
        if (align != 4) {
            throw Exception("Alignment of rte_ring_cons_cons is not 4 but ${align} bytes")
        }
}

@C
public struct rte_ring_rte_ring {
    public let memzone: CPointer<rte_memzone_rte_memzone>
    public let prod: rte_ring_prod_prod
    public let cons: rte_ring_cons_cons
    public let ring: CPointer<CPointer<Unit>>
    public init(memzone: CPointer<rte_memzone_rte_memzone>, prod: rte_ring_prod_prod, cons: rte_ring_cons_cons,
        ring: CPointer<CPointer<Unit>>) {
        this.memzone = memzone
        this.prod = prod
        this.cons = cons
        this.ring = ring
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<rte_ring_rte_ring>()
        if (size != 16) {
            throw Exception("Size of rte_ring_rte_ring is not 16 but ${size} bytes")
        }
        let align = alignOf<rte_ring_rte_ring>()
        if (align != 8) {
            throw Exception("Alignment of rte_ring_rte_ring is not 8 but ${align} bytes")
        }
}

@C
public struct rte_memzone_rte_memzone {}