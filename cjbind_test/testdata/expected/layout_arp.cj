package cjbind_ffi

public const ETHER_ADDR_LEN_ETHER_ADDR_LEN: Int64 = 6
public const ARP_HRD_ETHER_ARP_HRD_ETHER: Int64 = 1
public const ARP_OP_REQUEST_ARP_OP_REQUEST: Int64 = 1
public const ARP_OP_REPLY_ARP_OP_REPLY: Int64 = 2
public const ARP_OP_REVREQUEST_ARP_OP_REVREQUEST: Int64 = 3
public const ARP_OP_REVREPLY_ARP_OP_REVREPLY: Int64 = 4
public const ARP_OP_INVREQUEST_ARP_OP_INVREQUEST: Int64 = 8
public const ARP_OP_INVREPLY_ARP_OP_INVREPLY: Int64 = 9

// Ethernet address:
// A universally administered address is uniquely assigned to a device by its
// manufacturer. The first three octets (in transmission order) contain the
// Organizationally Unique Identifier (OUI). The following three (MAC-48 and
// EUI-48) octets are assigned by that organization with the only constraint
// of uniqueness.
// A locally administered address is assigned to a device by a network
// administrator and does not contain OUIs.
// See http://standards.ieee.org/regauth/groupmac/tutorial.html
@C
public struct ether_addr_ether_addr {
    let _cjbind_opaque_blob: VArray<UInt8, $6>
    public func clone(): ether_addr_ether_addr {
        return this
    }
    public func toString(): String {
        var output = "ether_addr_ether_addr {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $6>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<ether_addr_ether_addr>()
        if (size != 6) {
            throw Exception("Size of ether_addr_ether_addr is not 6 but ${size} bytes")
        }
        let align = alignOf<ether_addr_ether_addr>()
        if (align != 1) {
            throw Exception("Alignment of ether_addr_ether_addr is not 1 but ${align} bytes")
        }
}

// ARP header IPv4 payload.
@C
public struct arp_ipv4_arp_ipv4 {
    let _cjbind_opaque_blob: VArray<UInt8, $20>
    public func clone(): arp_ipv4_arp_ipv4 {
        return this
    }
    public func toString(): String {
        var output = "arp_ipv4_arp_ipv4 {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $20>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<arp_ipv4_arp_ipv4>()
        if (size != 20) {
            throw Exception("Size of arp_ipv4_arp_ipv4 is not 20 but ${size} bytes")
        }
        let align = alignOf<arp_ipv4_arp_ipv4>()
        if (align != 1) {
            throw Exception("Alignment of arp_ipv4_arp_ipv4 is not 1 but ${align} bytes")
        }
}

// ARP header.
@C
public struct arp_hdr_arp_hdr {
    let _cjbind_opaque_blob: VArray<UInt8, $28>
    public func clone(): arp_hdr_arp_hdr {
        return this
    }
    public func toString(): String {
        var output = "arp_hdr_arp_hdr {"
        output += " <opaque>"
        output += " }"
        return output
    }
    public init() {
        this._cjbind_opaque_blob = unsafe { zeroValue<VArray<UInt8, $28>>() }
    }
}

@When[debug]
let _ = {
    =>
        let size = sizeOf<arp_hdr_arp_hdr>()
        if (size != 28) {
            throw Exception("Size of arp_hdr_arp_hdr is not 28 but ${size} bytes")
        }
        let align = alignOf<arp_hdr_arp_hdr>()
        if (align != 1) {
            throw Exception("Alignment of arp_hdr_arp_hdr is not 1 but ${align} bytes")
        }
}
