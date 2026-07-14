package cjbind.ir

import std.collection.{ArrayList, HashMap}

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
