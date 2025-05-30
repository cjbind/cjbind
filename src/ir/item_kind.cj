package cjbind.ir

public enum ItemKind <: ToString {
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

    public func asModule(): ?Module {
        match (this) {
            case KindModule(v) => v
            case _ => None
        }
    }

    public func expectModule(): Module {
        this.asModule().getOrThrow()
    }

    public func isModule(): Bool {
        this.asModule().isSome()
    }

    public func toString(): String {
        match (this) {
            case KindModule(v) => "KindModule"
            case KindType(v) => "KindType"
            case KindFunction(v) => "KindFunction"
            case KindVar(v) => "KindVar"
        }
    }
}