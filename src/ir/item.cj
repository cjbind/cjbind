package cjbind.ir

import std.collection.HashSet

import cjbind.clang.SourceLocation

public type ItemSet = HashSet<ItemId>

public class Item {
    let id: ItemId
    let local_id: ItemId
    let next_child_local_id: ItemId
    let canonical_name: String
    let comment: ?String
    let parent_id: ItemId
    let kind: ItemKind
    let location: ?SourceLocation

    init(
        id: ItemId,
        comment: ?String,
        parent_id: ItemId,
        kind: ItemKind,
        location: ?SourceLocation
    ) {
        if (id != parent_id) {
            throw Exception("id != parent_id")
        }

        this.id = id
        this.local_id = 0
        this.next_child_local_id = 1
        this.canonical_name = ""
        this.parent_id = parent_id
        this.comment = comment
        this.kind = kind
        this.location = location
    }
}