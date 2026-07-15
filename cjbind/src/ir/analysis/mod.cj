package cjbind.ir.analysis

import cjbind.ir.*
import std.collection.{ArrayList, HashMap}

public class AnalysisResults <: AnalysisQueries {
    let haveVtable: ?HashMap<ItemId, HasVtableResult>
    let sizednessResults: ?HashMap<ItemId, SizednessResult>
    let usedTemplateParameters: ?HashMap<ItemId, ItemSet>

    init(
        haveVtable: HashMap<ItemId, HasVtableResult>,
        sizednessResults: HashMap<ItemId, SizednessResult>,
        usedTemplateParameters: HashMap<ItemId, ItemSet>
    ) {
        this.haveVtable = Some(haveVtable)
        this.sizednessResults = Some(sizednessResults)
        this.usedTemplateParameters = Some(usedTemplateParameters)
    }

    public init(usedTemplateParameters: HashMap<ItemId, ItemSet>) {
        this.haveVtable = None
        this.sizednessResults = None
        this.usedTemplateParameters = Some(usedTemplateParameters)
    }

    public func hasTemplateParameterResults(): Bool {
        return this.usedTemplateParameters.isSome()
    }

    public func hasVtableResults(): Bool {
        return this.haveVtable.isSome()
    }

    public func hasSizednessResults(): Bool {
        return this.sizednessResults.isSome()
    }

    public func usesTemplateParameter(
        ctx: CjbindContext,
        id: ItemId,
        parameter: TypeId
    ): Bool {
        if (ctx.isBlocklistedItem(id)) {
            return true
        }
        let canonicalParameter = canonicalItemId(ctx, parameter)
        return this.usedTemplateParameters
            .getOrThrow({=> Exception("template parameter usage analysis has not been computed")})
            .get(id)
            .map({parameters => parameters.contains(canonicalParameter)})
            .getOrDefault({=> false})
    }

    public func usedTemplateParams(ctx: CjbindContext, id: ItemId): Array<TypeId> {
        if (ctx.isBlocklistedItem(id)) {
            return allTemplateParams(id, ctx)
        }
        let result = ArrayList<TypeId>()
        let used = this.usedTemplateParameters
            .getOrThrow({=> Exception("template parameter usage analysis has not been computed")})
            .get(id)
            .getOrDefault({=> ItemSet()})
        for (parameter in allTemplateParams(id, ctx)) {
            let canonical = canonicalItemId(ctx, parameter)
            if (used.contains(canonical)) {
                result.add(parameter)
            }
        }
        return result.toArray()
    }

    public func usesAnyTemplateParameters(_: CjbindContext, id: ItemId): Bool {
        return this.usedTemplateParameters
            .getOrThrow({=> Exception("template parameter usage analysis has not been computed")})
            .get(id)
            .map({parameters => !parameters.isEmpty()})
            .getOrDefault({=> false})
    }

    public func hasVtablePointer(_: CjbindContext, id: ItemId): Bool {
        return this.haveVtable
            .getOrThrow({=> Exception("vtable analysis has not been computed")})
            .get(id)
            .getOrDefault({=> HasVtableResult.No}) ==
            HasVtableResult.SelfHasVtable
    }

    public func isZeroSized(_: CjbindContext, id: TypeId): Bool {
        return this.sizednessResults
            .getOrThrow({=> Exception("sizedness analysis has not been computed")})
            .get(id)
            .getOrDefault({=> SizednessResult.ZeroSized}) ==
            SizednessResult.ZeroSized
    }
}

public func computeCoreAnalyses(ctx: CjbindContext): AnalysisResults {
    let items = ctx.allowlistedItems.getOrThrow()
    let haveVtable = computeHasVtable(ctx, items)
    let sizednessResults = computeSizedness(ctx, items, haveVtable)
    let usedTemplateParameters = if (ctx.options.allowlistRecursively) {
        analyzeUsedTemplateParameters(ctx, items)
    } else {
        let usage = HashMap<ItemId, ItemSet>()
        for (id in items) {
            let parameters = ItemSet()
            for (parameter in selfTemplateParams(id, ctx)) {
                parameters.add(parameter)
            }
            usage.add(id, parameters)
        }
        usage
    }
    return AnalysisResults(
        haveVtable,
        sizednessResults,
        usedTemplateParameters
    )
}

enum ConstrainResult <: Equatable<ConstrainResult> {
    Changed
    | Same

    /// Combines two constraint passes. A combined pass reports a change when
    /// either constituent pass changed its incremental result.
    public func join(rhs: ConstrainResult): ConstrainResult {
        if (this == Changed || rhs == Changed) {
            return Changed
        }
        return Same
    }

    public operator func |(rhs: ConstrainResult): ConstrainResult {
        return this.join(rhs)
    }

    public operator func ==(rhs: ConstrainResult): Bool {
        return match ((this, rhs)) {
            case (Changed, Changed) | (Same, Same) => true
            case _ => false
        }
    }
}

/// A monotone analysis over a finite-height lattice.
///
/// `constrain` must only move the result for a node upwards in the lattice.
/// When it reports a change, every node returned by `eachDependingOn` is put
/// back into the worklist.
interface MonotoneFramework<Node, Output> {
    func initialWorklist(): Array<Node>
    func constrain(node: Node): ConstrainResult
    func eachDependingOn(node: Node): Array<Node>
    func finish(): Output
}

func analyze<Node, Output>(analysis: MonotoneFramework<Node, Output>): Output {
    let worklist = ArrayList<Node>()
    for (node in analysis.initialWorklist()) {
        worklist.add(node)
    }

    while (!worklist.isEmpty()) {
        let node = worklist[worklist.size - 1]
        worklist.remove(at: worklist.size - 1)
        if (analysis.constrain(node) == ConstrainResult.Changed) {
            for (dependent in analysis.eachDependingOn(node)) {
                worklist.add(dependent)
            }
        }
    }

    return analysis.finish()
}

class DependencyTracer <: Tracer {
    let current: ItemId
    let allowed: ItemSet
    let dependencies: HashMap<ItemId, ArrayList<ItemId>>
    let considerEdge: (EdgeKind) -> Bool

    init(
        current: ItemId,
        allowed: ItemSet,
        dependencies: HashMap<ItemId, ArrayList<ItemId>>,
        considerEdge: (EdgeKind) -> Bool
    ) {
        this.current = current
        this.allowed = allowed
        this.dependencies = dependencies
        this.considerEdge = considerEdge
    }

    public func visitKind(subItem: ItemId, kind: EdgeKind): Unit {
        if (!this.allowed.contains(subItem) || !this.considerEdge(kind)) {
            return
        }

        match (this.dependencies.get(subItem)) {
            case Some(dependents) => dependents.add(this.current)
            case None => this.dependencies.add(subItem, ArrayList<ItemId>([this.current]))
        }
    }
}

/// Builds the reverse dependency graph for a selected subset of IR edges.
func generateAnalysisDependencies(
    ctx: CjbindContext,
    items: ItemSet,
    considerEdge: (EdgeKind) -> Bool
): HashMap<ItemId, ArrayList<ItemId>> {
    let dependencies = HashMap<ItemId, ArrayList<ItemId>>()

    for (itemId in analysisItemsToArray(items)) {
        if (!dependencies.contains(itemId)) {
            dependencies.add(itemId, ArrayList<ItemId>())
        }

        let tracer = DependencyTracer(itemId, items, dependencies, considerEdge)
        ctx.resolveItem(itemId).trace(ctx, tracer, ())
    }

    return dependencies
}

func analysisItemsToArray(items: ItemSet): Array<ItemId> {
    let result = ArrayList<ItemId>()
    for (item in items) {
        result.add(item)
        var index = result.size - 1
        while (index > 0 && result[index - 1] > result[index]) {
            let previous = result[index - 1]
            result[index - 1] = result[index]
            result[index] = previous
            index -= 1
        }
    }
    return result.toArray()
}

class AnalysisEdgeCollector <: Tracer {
    let edges = ArrayList<Edge>()

    public func visitKind(item: ItemId, kind: EdgeKind): Unit {
        this.edges.add(Edge(item, kind))
    }
}

func traceAnalysisEdges(ctx: CjbindContext, id: ItemId): Array<Edge> {
    let collector = AnalysisEdgeCollector()
    ctx.resolveItem(id).trace(ctx, collector, ())
    return collector.edges.toArray()
}

func reachableAnalysisItems(ctx: CjbindContext, roots: ItemSet): ItemSet {
    let reachable = ItemSet()
    for (id in analysisInitialWorklist(ctx, roots)) {
        reachable.add(id)
    }
    return reachable
}

func analysisInitialWorklist(ctx: CjbindContext, roots: ItemSet): Array<ItemId> {
    let worklist = ArrayList<ItemId>()
    for (root in analysisItemsToArray(roots)) {
        worklist.add(root)
        for (edge in traceAnalysisEdges(ctx, root)) {
            worklist.add(edge.to)
        }
    }
    return worklist.toArray()
}

func addAnalysisDependency(
    dependencies: HashMap<ItemId, ArrayList<ItemId>>,
    prerequisite: ItemId,
    dependent: ItemId
): Unit {
    match (dependencies.get(prerequisite)) {
        case Some(items) => items.add(dependent)
        case None => dependencies.add(prerequisite, ArrayList<ItemId>([dependent]))
    }
}
