package cjbind.ir

import std.collection.*

class HasTypeParameterInArrayAnalysis <: MonotoneFramework<ItemId, ItemSet> {
    let ctx: CjbindContext
    let allowlistedItems: ItemSet
    let hasTypeParameterInArray = ItemSet()
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
                case EdgeKind.ConstructorEdge |
                    EdgeKind.DestructorEdge |
                    EdgeKind.FunctionReturnEdge |
                    EdgeKind.FunctionParameterEdge |
                    EdgeKind.InnerTypeEdge |
                    EdgeKind.InnerVarEdge |
                    EdgeKind.MethodEdge |
                    EdgeKind.GenericEdge => false
            }
        }
    }

    public func initialWorklist(): Array<ItemId> {
        return analysisItemsToArray(this.allowlistedItems)
    }

    public func constrain(id: ItemId): ConstrainResult {
        if (this.hasTypeParameterInArray.contains(id)) {
            return ConstrainResult.Same
        }

        let ty = match (this.ctx.resolveItem(id).asType()) {
            case Some(value) => value
            case None => return ConstrainResult.Same
        }

        if (let Some(instantiation) <- this.ctx.templateInstantiationFor(id)) {
            if (this.hasTypeParameterInArray.contains(instantiation.definition)) {
                this.hasTypeParameterInArray.add(id)
                return ConstrainResult.Changed
            }
            for (argument in instantiation.arguments) {
                if (this.hasTypeParameterInArray.contains(argument)) {
                    this.hasTypeParameterInArray.add(id)
                    return ConstrainResult.Changed
                }
            }
            return ConstrainResult.Same
        }

        let hasTypeParameter = match (ty.kind) {
            case TypeKind.TypeKindArray(inner, _) =>
                match (this.ctx.resolveType(inner).canonicalType(this.ctx).kind) {
                    case TypeKind.TypeKindTypeParam => true
                    case _ => false
                }
            case TypeKind.TypeKindAlias(inner) => this.hasTypeParameterInArray.contains(inner)
            case TypeKind.TypeKindTemplateAlias(inner, _) => this.hasTypeParameterInArray.contains(inner)
            case TypeKind.ResolvedTypeRef(inner) => this.hasTypeParameterInArray.contains(inner)
            case TypeKind.TypeKindObjCBlockPointer(inner) => this.hasTypeParameterInArray.contains(inner)
            case TypeKind.TypeKindComp(comp) =>
                var found = false
                for (base in comp.baseMembers) {
                    if (this.hasTypeParameterInArray.contains(base.ty)) {
                        found = true
                        break
                    }
                }
                if (!found) {
                    for (fieldType in normalFieldTypes(comp)) {
                        if (this.hasTypeParameterInArray.contains(fieldType)) {
                            found = true
                            break
                        }
                    }
                }
                found
            case TypeKind.TypeKindTemplateInstantiation(_) => false
            case _ => false
        }

        if (hasTypeParameter) {
            this.hasTypeParameterInArray.add(id)
            return ConstrainResult.Changed
        }
        return ConstrainResult.Same
    }

    public func eachDependingOn(id: ItemId): Array<ItemId> {
        return this.dependencies.get(id).map({items => items.toArray()}).getOrDefault {=> Array<ItemId>()}
    }

    public func finish(): ItemSet {
        return this.hasTypeParameterInArray
    }
}

func analyzeHasTypeParameterInArray(
    ctx: CjbindContext,
    allowlistedItems: ItemSet
): ItemSet {
    return analyze<ItemId, ItemSet>(HasTypeParameterInArrayAnalysis(ctx, allowlistedItems))
}
