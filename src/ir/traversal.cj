package cjbind.ir

import std.collection.{Queue, ArrayQueue}

// TODO: 实现可追踪行为的遍历
public class ItemTraversal <: Iterator<Item> {
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

    public func next(): ?Item {
        return None
    }
}

public enum EdgeKind {
    GenericEdge
    | FieldEdge
    | FunctionReturnEdge
    | FunctionParameterEdge
    | VarTypeEdge
    | TypeReferenceEdge
}

public interface Tracer {
    func visitKind(item: ItemId, kind: EdgeKind): Unit

    func visit(item: ItemId) {
        this.visitKind(item, EdgeKind.GenericEdge)
    }
}

public interface Trace<T, Extra> where T <: Tracer {
    func trace(context: CjbindContext, tracer: T, extra: Extra): Unit
}
