package cjbind.ir

import std.collection.{Queue, ArrayQueue}

public interface Tracer {
    func visitKind(item: ItemId, kind: EdgeKind): Unit

    func visit(item: ItemId) {
        this.visitKind(item, EdgeKind.GenericEdge)
    }
}

public interface Trace<T, Extra> where T <: Tracer {
    func trace(context: CjbindContext, tracer: T, extra: Extra): Unit
}

public enum EdgeKind {
    GenericEdge
    | FieldEdge
    | FunctionReturnEdge
    | FunctionParameterEdge
    | VarTypeEdge
    | TypeReferenceEdge
}

public struct Edge {
    public let to: ItemId
    public let kind: EdgeKind

    public init(
        to: ItemId,
        kind: EdgeKind
    ) {
        this.to = to
        this.kind = kind
    }
}

// TODO: 实现可追踪行为的遍历
public class ItemTraversal <: Iterator<ItemId> & Tracer {
    let ctx: CjbindContext
    let seen: ItemSet
    let queue: Queue<ItemId>
    var currentlyTraversing: ?ItemId = None

    public init(
        ctx: CjbindContext,
        roots: Array<ItemId>
    ) {
        this.ctx = ctx
        this.seen = ItemSet()
        this.queue = ArrayQueue<ItemId>()

        for (id in roots) {
            this.seen.add(id)
            this.queue.add(id)
        }
    }

    public func next(): ?ItemId {
        let id = match (queue.remove()) {
            case None => return None
            case Some(v) => v
        }

        let newlyDiscovered = this.seen.add(id)

        this.currentlyTraversing = Some(id)
        id.trace(this.ctx, this, ())
        this.currentlyTraversing = None

        return Some(id)
    }

    public func visitKind(item: ItemId, _: EdgeKind): Unit {
        let isNewlyDiscovered = this.seen.add(item)
        if (isNewlyDiscovered) {
            this.queue.add(item)
        }
    }
}
