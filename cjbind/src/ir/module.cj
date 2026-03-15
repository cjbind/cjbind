package cjbind.ir

public class Module {
    public let name: ?String
    public let children: ItemSet

    public init(name: ?String) {
        this.name = name
        this.children = ItemSet()
    }
}