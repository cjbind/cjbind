package cjbind.ir

public struct Module {
    let name: ?String
    let children: ItemSet = ItemSet()

    public init(name: ?String) {
        this.name = name
    }
}