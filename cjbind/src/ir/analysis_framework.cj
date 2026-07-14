package cjbind.ir

import std.collection.{ArrayList, ArrayQueue, HashMap, Queue}

public enum ConstrainResult <: Equatable<ConstrainResult> {
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
public interface MonotoneFramework<Node, Output> {
    func initialWorklist(): Array<Node>
    func constrain(node: Node): ConstrainResult
    func eachDependingOn(node: Node): Array<Node>
    func finish(): Output
}

/// Constructs a fresh analysis from all external state needed by one run.
///
/// Analysis construction is represented separately because interface methods
/// are instance-dispatched. The factory preserves a uniform `new(extra)`-like
/// contract without requiring callers to construct a partially initialized
/// analysis themselves.
public interface MonotoneFrameworkFactory<Node, Extra, Output> {
    func create(extra: Extra): MonotoneFramework<Node, Output>
}

public func analyze<Node, Output>(analysis: MonotoneFramework<Node, Output>): Output {
    let worklist: Queue<Node> = ArrayQueue<Node>()
    for (node in analysis.initialWorklist()) {
        worklist.add(node)
    }

    while (let Some(node) <- worklist.remove()) {
        if (analysis.constrain(node) == ConstrainResult.Changed) {
            for (dependent in analysis.eachDependingOn(node)) {
                worklist.add(dependent)
            }
        }
    }

    return analysis.finish()
}

/// Constructs and runs one fresh analysis using the supplied external state.
public func analyzeWith<Node, Extra, Output>(
    factory: MonotoneFrameworkFactory<Node, Extra, Output>,
    extra: Extra
): Output {
    return analyze<Node, Output>(factory.create(extra))
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
public func generateAnalysisDependencies(
    ctx: CjbindContext,
    items: ItemSet,
    considerEdge: (EdgeKind) -> Bool
): HashMap<ItemId, ArrayList<ItemId>> {
    let dependencies = HashMap<ItemId, ArrayList<ItemId>>()

    for (itemId in items) {
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
    }
    return result.toArray()
}
