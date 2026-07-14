package cjbind.ir

import std.collection.{ArrayList, HashMap}

/// The zero-sizedness lattice used while analyzing record layouts.
enum SizednessResult <: Equatable<SizednessResult> {
    ZeroSized
    | DependsOnTypeParam
    | NonZeroSized

    public operator func ==(rhs: SizednessResult): Bool {
        return match ((this, rhs)) {
            case (ZeroSized, ZeroSized) |
                (DependsOnTypeParam, DependsOnTypeParam) |
                (NonZeroSized, NonZeroSized) => true
            case _ => false
        }
    }

    func rank(): UInt8 {
        return match (this) {
            case ZeroSized => 0
            case DependsOnTypeParam => 1
            case NonZeroSized => 2
        }
    }

    public func join(rhs: SizednessResult): SizednessResult {
        if (this.rank() >= rhs.rank()) {
            return this
        }
        return rhs
    }
}

func sizednessResultFor(
    results: HashMap<ItemId, SizednessResult>,
    id: ItemId
): SizednessResult {
    return results.get(id).getOrDefault {=> SizednessResult.ZeroSized}
}

func analysisIsZeroSized(
    results: HashMap<ItemId, SizednessResult>,
    id: ItemId
): Bool {
    return sizednessResultFor(results, id) == SizednessResult.ZeroSized
}

/// Computes zero-sizedness for every selected IR type.
class SizednessAnalysis <: MonotoneFramework<ItemId, HashMap<ItemId, SizednessResult>> {
    let ctx: CjbindContext
    let items: ItemSet
    let haveVtable: HashMap<ItemId, HasVtableResult>
    let sized: HashMap<ItemId, SizednessResult> = HashMap()
    let dependencies: HashMap<ItemId, ArrayList<ItemId>>

    public init(
        ctx: CjbindContext,
        items: ItemSet,
        haveVtable: HashMap<ItemId, HasVtableResult>
    ) {
        this.ctx = ctx
        this.items = items
        this.haveVtable = haveVtable
        let typeItems = ItemSet()
        for (id in analysisItemsToArray(items)) {
            if (ctx.resolveItem(id).asType().isSome()) {
                typeItems.add(id)
            }
        }
        this.dependencies = generateAnalysisDependencies(ctx, typeItems, considerSizednessEdge)
    }

    public func initialWorklist(): Array<ItemId> {
        let result = ArrayList<ItemId>()
        for (id in analysisItemsToArray(this.items)) {
            if (this.ctx.resolveItem(id).asType().isSome()) {
                result.add(id)
            }
        }
        return result.toArray()
    }

    public func resultFor(id: ItemId): SizednessResult {
        return sizednessResultFor(this.sized, id)
    }

    public func finish(): HashMap<ItemId, SizednessResult> {
        return this.sized
    }

    func hasVtablePointer(id: ItemId): Bool {
        return this.haveVtable
            .get(id)
            .map({result => result == HasVtableResult.SelfHasVtable})
            .getOrDefault {=> false}
    }

    func insert(id: ItemId, result: SizednessResult): ConstrainResult {
        if (result == SizednessResult.ZeroSized) {
            return ConstrainResult.Same
        }

        let old = this.resultFor(id)
        let joined = old.join(result)
        if (joined == old) {
            return ConstrainResult.Same
        }
        this.sized.add(id, joined)
        return ConstrainResult.Changed
    }

    func forward(from: ItemId, to: ItemId): ConstrainResult {
        return this.insert(to, this.resultFor(from))
    }

    public func constrain(id: ItemId): ConstrainResult {
        if (this.resultFor(id) == SizednessResult.NonZeroSized) {
            return ConstrainResult.Same
        }

        if (this.hasVtablePointer(id)) {
            return this.insert(id, SizednessResult.NonZeroSized)
        }

        let item = this.ctx.resolveItem(id)
        let ty = match (item.asType()) {
            case Some(value) => value
            case None => return ConstrainResult.Same
        }

        if (item.isOpaque(this.ctx, ())) {
            let result = analysisLayout(ty, this.ctx)
                .map {
                    layout => if (layout.size == 0) {
                        SizednessResult.ZeroSized
                    } else {
                        SizednessResult.NonZeroSized
                    }
                }
                .getOrDefault {=> SizednessResult.ZeroSized}
            return this.insert(id, result)
        }

        if (let Some(instantiation) <- this.ctx.templateInstantiationFor(id)) {
            return this.forward(instantiation.definition, id)
        }

        return match (ty.kind) {
            case TypeKind.TypeKindVoid => this.insert(id, SizednessResult.ZeroSized)
            case TypeKind.TypeKindTypeParam => this.insert(id, SizednessResult.DependsOnTypeParam)

            case TypeKind.TypeKindInt(_) |
                TypeKind.TypeKindFloat(_) |
                TypeKind.TypeKindComplex(_) |
                TypeKind.TypeKindFunction(_) |
                TypeKind.TypeKindEnum(_) |
                TypeKind.TypeKindReference(_) |
                TypeKind.TypeKindNullPtr |
                TypeKind.TypeKindObjCInterface(_) |
                TypeKind.TypeKindObjCId |
                TypeKind.TypeKindObjCSel |
                TypeKind.TypeKindPointer(_) => this.insert(id, SizednessResult.NonZeroSized)

            case TypeKind.TypeKindAlias(inner) => this.forward(inner, id)
            case TypeKind.TypeKindTemplateAlias(inner, _) => this.forward(inner, id)
            case TypeKind.TypeKindObjCBlockPointer(inner) => this.forward(inner, id)
            case TypeKind.ResolvedTypeRef(inner) => this.forward(inner, id)

            case TypeKind.TypeKindTemplateInstantiation(_) => ConstrainResult.Same

            case TypeKind.TypeKindArray(_, length) =>
                if (length == 0) {
                    this.insert(id, SizednessResult.ZeroSized)
                } else {
                    this.insert(id, SizednessResult.NonZeroSized)
                }

            case TypeKind.TypeKindVector(_, _) => this.insert(id, SizednessResult.NonZeroSized)

            case TypeKind.TypeKindComp(info) =>
                if (info.hasFields()) {
                    return this.insert(id, SizednessResult.NonZeroSized)
                }

                var result = SizednessResult.ZeroSized
                for (base in info.baseMembers) {
                    result = result.join(this.resultFor(base.ty))
                }
                this.insert(id, result)

            case TypeKind.TypeKindOpaque =>
                throw Exception("opaque type was not handled before sizedness dispatch")
            case TypeKind.UnresolvedTypeRef(_, _, _) =>
                throw Exception("type references must be resolved before sizedness analysis")
        }
    }

    public func eachDependingOn(id: ItemId): Array<ItemId> {
        return this.dependencies.get(id).map({items => items.toArray()}).getOrDefault {=> Array<ItemId>()}
    }
}

func considerSizednessEdge(kind: EdgeKind): Bool {
    return match (kind) {
        case EdgeKind.TemplateArgumentEdge |
            EdgeKind.TemplateDeclarationEdge |
            EdgeKind.TemplateParameterDefinitionEdge |
            EdgeKind.TypeReferenceEdge |
            EdgeKind.BaseMemberEdge |
            EdgeKind.FieldEdge => true
        case _ => false
    }
}

func computeSizedness(
    ctx: CjbindContext,
    items: ItemSet,
    haveVtable: HashMap<ItemId, HasVtableResult>
): HashMap<ItemId, SizednessResult> {
    return analyze<ItemId, HashMap<ItemId, SizednessResult>>(
        SizednessAnalysis(ctx, items, haveVtable)
    )
}
