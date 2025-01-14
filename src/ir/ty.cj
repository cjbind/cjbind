package cjbind.ir

public class Type {
    public let name: ?String
    public let layout: ?Layout
    public let kind: TypeKind
    public let isConst: Bool

    public init(
        name: ?String,
        layout: ?Layout,
        kind: TypeKind,
        isConst: Bool
    ) {
        this.name = name
        this.layout = layout
        this.kind = kind
        this.isConst = isConst
    }
}

public enum TypeKind {
    TK_Void |
    TK_NullPtr |
    Comp(CompInfo)
}