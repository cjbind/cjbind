package cjbind.ir

import std.collection.HashSet

import cjbind.clang
import cjbind.result.Result

public type ItemSet = HashSet<ItemId>

public class Item {
    let id: ItemId
    let localId: ItemId
    let nextChildLocalId: ItemId
    let canonicalName: String
    let comment: ?String
    let parentId: ItemId
    let kind: ItemKind
    let location: ?clang.SourceLocation

    init(
        id: ItemId,
        comment: ?String,
        parentId: ItemId,
        kind: ItemKind,
        location: ?clang.SourceLocation
    ) {
        if (id != parentId) {
            throw Exception("id != parent_id")
        }

        this.id = id
        this.localId = 0
        this.nextChildLocalId = 1
        this.canonicalName = ""
        this.parentId = parentId
        this.comment = comment
        this.kind = kind
        this.location = location
    }

    public func parse(
        cursor: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): Result<ItemId, ParseError> {
        if (!cursor.isValid()) {
            return Result.Err(ParseError.Continue)
        }

        let comment = cursor.rawComment()
        let currentModule = ctx.currentModule
        let releventParentId = parentId ?? currentModule
        
        throw Exception("TODO")
    }

    public static func newOpaqueType(
        withId: ItemId,
        ty: clang.Type,
        ctx: CjbindContext,
    ) {
        let location = ty.declaration().location()
        let ty = 
    }

    public static func fromTy(
        ty: clang.Type,
        location: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): Result<TypeId, ParseError> {
        let _id = ctx.nextItemId()
        return Item.fromTyWithId(_id, ty, location, parentId, ctx)
    }

    public static func fromTyWithId(
        id: ItemId,
        ty: clang.Type,
        location: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): Result<TypeId, ParseError> {
        if (let Some(par) <- ty.declaration().fallibleSemanticParent()) {
            return 
        }
    }
}