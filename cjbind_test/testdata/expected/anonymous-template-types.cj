package cjbind_ffi

@C
public struct Bar {
    public var member: UInt8
    private init(member: UInt8) {
        this.member = member
    }
}

@C
public struct Lobo {
    public var also_member: UInt8
    private init(also_member: UInt8) {
        this.also_member = also_member
    }
}

public type AliasWithAnonType = UInt8
