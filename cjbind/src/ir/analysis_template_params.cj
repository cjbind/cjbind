package cjbind.ir

import std.collection.*

class UsedTemplateParametersAnalysis <: MonotoneFramework<ItemId, HashMap<ItemId, ItemSet>> {
    let ctx: CjbindContext
    let allowlistedItems: ItemSet
    let analysisItems: ItemSet
    let used = HashMap<ItemId, ItemSet>()
    let dependencies: HashMap<ItemId, ArrayList<ItemId>>

    public init(ctx: CjbindContext, allowlistedItems: ItemSet) {
        this.ctx = ctx
        this.allowlistedItems = allowlistedItems
        this.analysisItems = reachableAnalysisItems(ctx, allowlistedItems)
        this.dependencies = HashMap<ItemId, ArrayList<ItemId>>()

        for (id in analysisItemsToArray(this.analysisItems)) {
            if (!this.dependencies.contains(id)) {
                this.dependencies.add(id, ArrayList<ItemId>())
            }
            usedSet(this.used, id)
            for (edge in traceAnalysisEdges(ctx, id)) {
                usedSet(this.used, edge.to)
                addAnalysisDependency(this.dependencies, edge.to, id)
            }

            if (let Some(instantiation) <- ctx.templateInstantiationFor(id)) {
                let parameters = selfTemplateParams(instantiation.definition, ctx)
                let count = min(instantiation.arguments.size, parameters.size)
                for (index in 0..count) {
                    let argument = canonicalItemId(ctx, instantiation.arguments[index])
                    let parameter = canonicalItemId(ctx, parameters[index])
                    usedSet(this.used, argument)
                    usedSet(this.used, parameter)
                    addAnalysisDependency(this.dependencies, argument, parameter)
                }
            }
        }
    }

    static func considerEdge(kind: EdgeKind): Bool {
        return match (kind) {
            case EdgeKind.TemplateArgumentEdge |
                EdgeKind.BaseMemberEdge |
                EdgeKind.FieldEdge |
                EdgeKind.ConstructorEdge |
                EdgeKind.DestructorEdge |
                EdgeKind.VarTypeEdge |
                EdgeKind.FunctionReturnEdge |
                EdgeKind.FunctionParameterEdge |
                EdgeKind.TypeReferenceEdge => true
            case EdgeKind.InnerVarEdge |
                EdgeKind.InnerTypeEdge |
                EdgeKind.MethodEdge |
                EdgeKind.TemplateDeclarationEdge |
                EdgeKind.TemplateParameterDefinitionEdge |
                EdgeKind.GenericEdge => false
        }
    }

    func constrainInstantiation(
        id: ItemId,
        target: ItemSet,
        instantiation: TemplateInstantiation
    ): Unit {
        let definitionUsed = usedSet(this.used, instantiation.definition)
        let parameters = selfTemplateParams(instantiation.definition, this.ctx)
        let count = min(instantiation.arguments.size, parameters.size)
        for (index in 0..count) {
            let parameter = parameters[index]
            if (!definitionUsed.contains(parameter)) {
                continue
            }

            let argument = canonicalItemId(this.ctx, instantiation.arguments[index])
            if (argument != id) {
                extendSet(target, usedSet(this.used, argument))
            }
        }
    }

    func constrainBlocklistedInstantiation(
        id: ItemId,
        target: ItemSet,
        instantiation: TemplateInstantiation
    ): Unit {
        for (rawArgument in instantiation.arguments) {
            let argument = canonicalItemId(this.ctx, rawArgument)
            if (argument != id) {
                extendSet(target, usedSet(this.used, argument))
            }
        }
    }

    func constrainJoin(id: ItemId, target: ItemSet): Unit {
        for (edge in traceAnalysisEdges(this.ctx, id)) {
            if (edge.to != id && UsedTemplateParametersAnalysis.considerEdge(edge.kind)) {
                extendSet(target, usedSet(this.used, edge.to))
            }
        }
    }

    public func initialWorklist(): Array<ItemId> {
        return analysisInitialWorklist(this.ctx, this.allowlistedItems)
    }

    public func constrain(id: ItemId): ConstrainResult {
        let target = usedSet(this.used, id)
        let originalSize = target.size
        let ty = this.ctx.resolveItem(id).asType()
        if (let Some(value) <- ty) {
            if (let TypeKind.TypeKindTypeParam <- value.kind) {
                target.add(id)
            } else if (let Some(instantiation) <- this.ctx.templateInstantiationFor(id)) {
                if (this.allowlistedItems.contains(instantiation.definition)) {
                    this.constrainInstantiation(id, target, instantiation)
                } else {
                    this.constrainBlocklistedInstantiation(id, target, instantiation)
                }
            } else {
                this.constrainJoin(id, target)
            }
        } else {
            this.constrainJoin(id, target)
        }
        if (target.size != originalSize) {
            return ConstrainResult.Changed
        }
        return ConstrainResult.Same
    }

    public func eachDependingOn(id: ItemId): Array<ItemId> {
        return this.dependencies.get(id).map({items => items.toArray()}).getOrDefault {=> Array<ItemId>()}
    }

    public func finish(): HashMap<ItemId, ItemSet> {
        return this.used
    }
}

func analyzeUsedTemplateParameters(
    ctx: CjbindContext,
    allowlistedItems: ItemSet
): HashMap<ItemId, ItemSet> {
    return analyze<ItemId, HashMap<ItemId, ItemSet>>(
        UsedTemplateParametersAnalysis(ctx, allowlistedItems)
    )
}
