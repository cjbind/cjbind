package cjbind.ir

import std.collection.*

class HasDestructorAnalysis <: MonotoneFramework<ItemId, ItemSet> {
    let ctx: CjbindContext
    let allowlistedItems: ItemSet
    let haveDestructor = ItemSet()
    let dependencies: HashMap<ItemId, ArrayList<ItemId>>

    public init(ctx: CjbindContext, allowlistedItems: ItemSet) {
        this.ctx = ctx
        this.allowlistedItems = allowlistedItems
        this.dependencies = generateAnalysisDependencies(ctx, allowlistedItems) {
            kind =>
            match (kind) {
                case EdgeKind.TypeReferenceEdge |
                    EdgeKind.BaseMemberEdge |
                    EdgeKind.FieldEdge |
                    EdgeKind.TemplateArgumentEdge |
                    EdgeKind.TemplateDeclarationEdge => true
                case _ => false
            }
        }
    }

    public func initialWorklist(): Array<ItemId> {
        return analysisItemsToArray(this.allowlistedItems)
    }

    public func constrain(id: ItemId): ConstrainResult {
        if (this.haveDestructor.contains(id)) {
            return ConstrainResult.Same
        }

        let ty = match (this.ctx.resolveItem(id).asType()) {
            case Some(value) => value
            case None => return ConstrainResult.Same
        }

        if (let Some(instantiation) <- this.ctx.templateInstantiationFor(id)) {
            if (this.haveDestructor.contains(instantiation.definition)) {
                this.haveDestructor.add(id)
                return ConstrainResult.Changed
            }
            for (argument in instantiation.arguments) {
                if (this.haveDestructor.contains(argument)) {
                    this.haveDestructor.add(id)
                    return ConstrainResult.Changed
                }
            }
            return ConstrainResult.Same
        }

        let hasDestructor = match (ty.kind) {
            case TypeKind.TypeKindAlias(inner) => this.haveDestructor.contains(inner)
            case TypeKind.TypeKindTemplateAlias(inner, _) => this.haveDestructor.contains(inner)
            case TypeKind.ResolvedTypeRef(inner) => this.haveDestructor.contains(inner)
            case TypeKind.TypeKindComp(comp) =>
                if (comp.hasDestructor) {
                    true
                } else {
                    match (comp.kind) {
                        case CompKind.CompKindUnion => false
                        case CompKind.CompKindStruct =>
                            var found = false
                            for (base in comp.baseMembers) {
                                if (this.haveDestructor.contains(base.ty)) {
                                    found = true
                                    break
                                }
                            }
                            if (!found) {
                                for (fieldType in normalFieldTypes(comp)) {
                                    if (this.haveDestructor.contains(fieldType)) {
                                        found = true
                                        break
                                    }
                                }
                            }
                            found
                    }
                }
            case TypeKind.TypeKindTemplateInstantiation(_) => false
            case _ => false
        }

        if (hasDestructor) {
            this.haveDestructor.add(id)
            return ConstrainResult.Changed
        }
        return ConstrainResult.Same
    }

    public func eachDependingOn(id: ItemId): Array<ItemId> {
        return this.dependencies.get(id).map({items => items.toArray()}).getOrDefault {=> Array<ItemId>()}
    }

    public func finish(): ItemSet {
        return this.haveDestructor
    }
}

func analyzeHasDestructor(
    ctx: CjbindContext,
    allowlistedItems: ItemSet
): ItemSet {
    return analyze<ItemId, ItemSet>(HasDestructorAnalysis(ctx, allowlistedItems))
}
