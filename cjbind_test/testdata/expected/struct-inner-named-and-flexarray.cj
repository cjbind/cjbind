package cjbind_ffi

@C
public struct rte_ring_prod_prod {
    public let watermark: UInt32
    public func clone(): rte_ring_prod_prod {
        return this
    }
    public func toString(): String {
        var output = "rte_ring_prod_prod {"
        output += " watermark: "
        output += this.watermark.toString()
        output += " }"
        return output
    }
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
    public func clone(): rte_ring_cons_cons {
        return this
    }
    public func toString(): String {
        var output = "rte_ring_cons_cons {"
        output += " sc_dequeue: "
        output += this.sc_dequeue.toString()
        output += " }"
        return output
    }
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
    public func toString(): String {
        var output = "rte_ring_rte_ring {"
        output += " memzone: "
        output += CPointer<Unit>(this.memzone).toUIntNative().toString()
        output += ", prod: "
        output += this.prod.toString()
        output += ", cons: "
        output += this.cons.toString()
        output += ", ring: "
        output += "<incomplete array>"
        output += " }"
        return output
    }
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
public struct rte_memzone_rte_memzone {
    let _cjbind_empty: UInt8
    public func clone(): rte_memzone_rte_memzone {
        return this
    }
    public func toString(): String {
        var output = "rte_memzone_rte_memzone {"
        output += " }"
        return output
    }
    public init(_cjbind_empty: UInt8) {
        this._cjbind_empty = _cjbind_empty
    }
}
