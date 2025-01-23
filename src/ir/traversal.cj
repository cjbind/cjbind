package cjbind.ir

import std.collection.{Queue, ArrayQueue}

public class ItemTraversal {
    let ctx: CjbindContext
    let seen: ItemSet
    let queue: Queue<ItemId>
    var currentlyTraversing: ?ItemId = None

    public init(
        ctx: CjbindContext,
        seen: ItemSet
    ) {
        this.ctx = ctx
        this.seen = seen
        this.queue = ArrayQueue<ItemId>()
    }
}