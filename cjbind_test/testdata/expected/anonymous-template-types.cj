package cjbind_ffi

@C
public struct Bar {
    public let member: UInt8
    public init(member: UInt8) {
        this.member = member
    }
}

@C
public struct Lobo {
    public let also_member: UInt8
    public init(also_member: UInt8) {
        this.also_member = also_member
    }
}

public type AliasWithAnonType = UInt8
