package cjbind.ir

import std.collection.{ArrayList, HashMap}

/// The location of a record's virtual-table pointer.
enum HasVtableResult <: Equatable<HasVtableResult> {
    No
    | SelfHasVtable
    | BaseHasVtable

    public operator func ==(rhs: HasVtableResult): Bool {
        return match ((this, rhs)) {
            case (No, No) |
                (SelfHasVtable, SelfHasVtable) |
                (BaseHasVtable, BaseHasVtable) => true
            case _ => false
        }
    }

    func rank(): UInt8 {
        return match (this) {
            case No => 0
            case SelfHasVtable => 1
            case BaseHasVtable => 2
        }
    }

    public func join(rhs: HasVtableResult): HasVtableResult {
        if (this.rank() >= rhs.rank()) {
            return this
        }
        return rhs
    }
}

func hasVtableResultFor(
    results: HashMap<ItemId, HasVtableResult>,
    id: ItemId
): HasVtableResult {
    return results.get(id).getOrDefault {=> HasVtableResult.No}
}

func analysisHasVtable(
    results: HashMap<ItemId, HasVtableResult>,
    id: ItemId
): Bool {
    return hasVtableResultFor(results, id) != HasVtableResult.No
}

func analysisHasVtablePointer(
    results: HashMap<ItemId, HasVtableResult>,
    id: ItemId
): Bool {
    return hasVtableResultFor(results, id) == HasVtableResult.SelfHasVtable
}

/// Computes whether each selected IR item contains a virtual-table pointer.
class HasVtableAnalysis <: MonotoneFramework<ItemId, HashMap<ItemId, HasVtableResult>> {
    let ctx: CjbindContext
    let items: ItemSet
    let haveVtable: HashMap<ItemId, HasVtableResult> = HashMap()
    let dependencies: HashMap<ItemId, ArrayList<ItemId>>

    public init(ctx: CjbindContext, items: ItemSet) {
        this.ctx = ctx
        this.items = items
        this.dependencies = generateAnalysisDependencies(ctx, items, considerHasVtableEdge)
    }

    public func initialWorklist(): Array<ItemId> {
        return analysisItemsToArray(this.items)
    }

    public func resultFor(id: ItemId): HasVtableResult {
        return hasVtableResultFor(this.haveVtable, id)
    }

    public func finish(): HashMap<ItemId, HasVtableResult> {
        return this.haveVtable
    }

    func insert(id: ItemId, result: HasVtableResult): ConstrainResult {
        if (result == HasVtableResult.No) {
            return ConstrainResult.Same
        }

        let old = this.resultFor(id)
        let joined = old.join(result)
        if (joined == old) {
            return ConstrainResult.Same
        }
        this.haveVtable.add(id, joined)
        return ConstrainResult.Changed
    }

    func forward(from: ItemId, to: ItemId): ConstrainResult {
        return this.insert(to, this.resultFor(from))
    }

    public func constrain(id: ItemId): ConstrainResult {
        let item = this.ctx.resolveItem(id)
        let ty = match (item.asType()) {
            case Some(value) => value
            case None => return ConstrainResult.Same
        }

        if (let Some(instantiation) <- this.ctx.templateInstantiationFor(id)) {
            return this.forward(instantiation.definition, id)
        }

        return match (ty.kind) {
            case TypeKind.TypeKindAlias(inner) => this.forward(inner, id)
            case TypeKind.TypeKindTemplateAlias(inner, _) => this.forward(inner, id)
            case TypeKind.ResolvedTypeRef(inner) => this.forward(inner, id)
            case TypeKind.TypeKindReference(inner) => this.forward(inner, id)

            case TypeKind.TypeKindComp(info) =>
                var result = HasVtableResult.No
                if (info.hasOwnVirtualMethod) {
                    result = result.join(HasVtableResult.SelfHasVtable)
                }
                for (base in info.baseMembers) {
                    if (this.resultFor(base.ty) != HasVtableResult.No) {
                        result = result.join(HasVtableResult.BaseHasVtable)
                    }
                }
                this.insert(id, result)

            case TypeKind.TypeKindTemplateInstantiation(_) => ConstrainResult.Same

            case _ => ConstrainResult.Same
        }
    }

    public func eachDependingOn(id: ItemId): Array<ItemId> {
        return this.dependencies.get(id).map({items => items.toArray()}).getOrDefault {=> Array<ItemId>()}
    }
}

func considerHasVtableEdge(kind: EdgeKind): Bool {
    return match (kind) {
        case EdgeKind.TypeReferenceEdge |
            EdgeKind.BaseMemberEdge |
            EdgeKind.TemplateDeclarationEdge => true
        case _ => false
    }
}

func computeHasVtable(
    ctx: CjbindContext,
    items: ItemSet
): HashMap<ItemId, HasVtableResult> {
    return analyze<ItemId, HashMap<ItemId, HasVtableResult>>(HasVtableAnalysis(ctx, items))
}
