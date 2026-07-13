package cjbind.ir

public enum ModuleKind {
    Normal
    | Inline
}

public class Module {
    public let name: ?String
    public let kind: ModuleKind
    public let children: ItemSet

    public init(name: ?String, kind!: ModuleKind = ModuleKind.Normal) {
        this.name = name
        this.kind = kind
        this.children = ItemSet()
    }

    public func isInline(): Bool {
        return match (this.kind) {
            case ModuleKind.Inline => true
            case ModuleKind.Normal => false
        }
    }
}
