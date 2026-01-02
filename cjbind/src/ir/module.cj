package cjbind.ir

public struct Module {
    public let name: ?String
    public let children: ItemSet = ItemSet()

    public init(name: ?String) {
        this.name = name
    }
}