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
    | BaseMemberEdge
    | InnerTypeEdge
    | InnerVarEdge
    | MethodEdge
    | ConstructorEdge
    | DestructorEdge
    | TemplateArgumentEdge
    | TemplateDeclarationEdge
    | TemplateParameterDefinitionEdge
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

public class ItemTraversal <: Iterator<ItemId> & Tracer {
    let ctx: CjbindContext
    let seen: ItemSet
    let queue: Queue<ItemId>
    let predicate: (CjbindContext, Edge) -> Bool
    var currentlyTraversing: ?ItemId = None

    public init(
        ctx: CjbindContext,
        roots: Array<ItemId>
    ) {
        this.ctx = ctx
        this.seen = ItemSet()
        this.queue = ArrayQueue<ItemId>()
        this.predicate = {_ctx, _edge => true}

        for (id in roots) {
            this.seen.add(id)
            this.queue.add(id)
        }
    }

    public init(
        ctx: CjbindContext,
        roots: Array<ItemId>,
        predicate: (CjbindContext, Edge) -> Bool
    ) {
        this.ctx = ctx
        this.seen = ItemSet()
        this.queue = ArrayQueue<ItemId>()
        this.predicate = predicate

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

        this.currentlyTraversing = Some(id)
        id.trace(this.ctx, this, ())
        this.currentlyTraversing = None

        return Some(id)
    }

    public func visitKind(item: ItemId, kind: EdgeKind): Unit {
        if (!this.predicate(this.ctx, Edge(item, kind))) {
            return
        }
        let isNewlyDiscovered = this.seen.add(item)
        if (isNewlyDiscovered) {
            this.queue.add(item)
        }
    }
}
