package cjbind.ir

public enum ItemKind {
    KindModule(Module) |
    KindType(Type) |
    KindFunction(Function) |
    KindVar(Var)

    public func asType(): ?Type {
        match (this) {
            case KindType(v) => v
            case _ => None
        }
    }

    public func expectType(): Type {
        this.asType().getOrThrow()
    }

    public func isType(): Bool {
        this.asType().isSome()
    }

    public func asFunction(): ?Function {
        match (this) {
            case KindFunction(v) => v
            case _ => None
        }
    }

    public func expectFunction(): Function {
        this.asFunction().getOrThrow()
    }

    public func isFunction(): Bool {
        this.asFunction().isSome()
    }

    public func asVar(): ?Var {
        match (this) {
            case KindVar(v) => v
            case _ => None
        }
    }

    public func expectVar(): Var {
        this.asVar().getOrThrow()
    }

    public func isVar(): Bool {
        this.asVar().isSome()
    }
}