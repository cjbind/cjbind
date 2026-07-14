package cjbind.ir

import std.collection.*

public class HasFloatAnalysis <: MonotoneFramework<ItemId, ItemSet> {
    let ctx: CjbindContext
    let allowlistedItems: ItemSet
    let hasFloat = ItemSet()
    let dependencies: HashMap<ItemId, ArrayList<ItemId>>

    public init(ctx: CjbindContext, allowlistedItems: ItemSet) {
        this.ctx = ctx
        this.allowlistedItems = allowlistedItems
        this.dependencies = generateAnalysisDependencies(ctx, allowlistedItems) {
            kind =>
            match (kind) {
                case EdgeKind.BaseMemberEdge |
                    EdgeKind.FieldEdge |
                    EdgeKind.TypeReferenceEdge |
                    EdgeKind.VarTypeEdge |
                    EdgeKind.TemplateArgumentEdge |
                    EdgeKind.TemplateDeclarationEdge |
                    EdgeKind.TemplateParameterDefinitionEdge => true
                case _ => false
            }
        }
    }

    public func initialWorklist(): Array<ItemId> {
        return analysisItemsToArray(this.allowlistedItems)
    }

    public func constrain(id: ItemId): ConstrainResult {
        if (this.hasFloat.contains(id)) {
            return ConstrainResult.Same
        }

        let ty = match (this.ctx.resolveItem(id).asType()) {
            case Some(value) => value
            case None => return ConstrainResult.Same
        }

        if (let Some(instantiation) <- this.ctx.templateInstantiationFor(id)) {
            if (!hasMaterializedSpecializationBody(ty, instantiation)) {
                if (this.hasFloat.contains(instantiation.definition)) {
                    this.hasFloat.add(id)
                    return ConstrainResult.Changed
                }
                for (argument in instantiation.arguments) {
                    if (this.hasFloat.contains(argument)) {
                        this.hasFloat.add(id)
                        return ConstrainResult.Changed
                    }
                }
                return ConstrainResult.Same
            }
        }

        let containsFloat = match (ty.kind) {
            case TypeKind.TypeKindFloat(_) | TypeKind.TypeKindComplex(_) => true
            case TypeKind.TypeKindArray(inner, _) => this.hasFloat.contains(inner)
            case TypeKind.TypeKindVector(inner, _) => this.hasFloat.contains(inner)
            case TypeKind.TypeKindAlias(inner) => this.hasFloat.contains(inner)
            case TypeKind.TypeKindTemplateAlias(inner, _) => this.hasFloat.contains(inner)
            case TypeKind.ResolvedTypeRef(inner) => this.hasFloat.contains(inner)
            case TypeKind.TypeKindObjCBlockPointer(inner) => this.hasFloat.contains(inner)
            case TypeKind.TypeKindComp(comp) =>
                var found = false
                for (base in comp.baseMembers) {
                    if (this.hasFloat.contains(base.ty)) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    for (fieldType in allFieldTypes(comp)) {
                        if (this.hasFloat.contains(fieldType)) {
                            found = true
                            break
                        }
                    }
                }
                found
            case TypeKind.TypeKindTemplateInstantiation(_) => false
            case _ => false
        }

        if (containsFloat) {
            this.hasFloat.add(id)
            return ConstrainResult.Changed
        }
        return ConstrainResult.Same
    }

    public func eachDependingOn(id: ItemId): Array<ItemId> {
        return this.dependencies.get(id).map({items => items.toArray()}).getOrDefault {=> Array<ItemId>()}
    }

    public func finish(): ItemSet {
        return this.hasFloat
    }
}

public func analyzeHasFloat(
    ctx: CjbindContext,
    allowlistedItems: ItemSet
): ItemSet {
    return analyze<ItemId, ItemSet>(HasFloatAnalysis(ctx, allowlistedItems))
}
