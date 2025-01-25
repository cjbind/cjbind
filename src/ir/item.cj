package cjbind.ir

import std.collection.{HashSet, contains}
import cjbind.clang
import cjbind.result.Result

public type ItemSet = HashSet<ItemId>

public interface IsOpaque<Extra> {
    func isOpaque(ctx: CjbindContext, extra: Extra): Bool
}

public class Item <: Trace<Tracer, Unit> & IsOpaque<Unit> {
    public let id: ItemId
    public let localId: ItemId
    public let nextChildLocalId: ItemId
    public let canonicalName: ?String
    public let comment: ?String
    public let parentId: ItemId
    public var kind: ItemKind
    public let location: ?clang.SourceLocation

    init(
        id: ItemId,
        comment: ?String,
        parentId: ItemId,
        kind: ItemKind,
        location: ?clang.SourceLocation
    ) {
        if (!(id != parentId || kind.isModule())) {
            throw Exception("item error")
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

    public func getCanonicalName(ctx: CjbindContext): String {
        match (this.canonicalName) {
            case Some(v) => v
            case None =>
                let n = item.realCannonicalName(this, ctx)
        }
    }

    public func asModule(): Option<Module> {
        match (this.kind) {
            case ItemKind.KindModule(module) => Some(module)
            case _ => None
        }
    }

    public func asType(): Option<Type> {
        match (this.kind) {
            case ItemKind.KindType(typeInfo) => Some(typeInfo)
            case _ => None
        }
    }

    // cjlint-ignore -start !G.ITF.04
    public func trace(ctx: CjbindContext, tracer: Tracer, _: Unit) {
        match (this.kind) {
            case ItemKind.KindType(ty) =>
                if (ty.shouldBeTracedUnconditionally() || !this.isOpaque(ctx, ())) {
                    ty.trace(ctx, tracer, this)
                }
            case ItemKind.KindFunction(fun) => tracer.visit(fun.signature)
            case ItemKind.KindVar(v) => tracer.visitKind(v.ty, EdgeKind.VarTypeEdge)
            case ItemKind.KindModule(m) => ()
        }
    }
    // cjlint-ignore -end

    public func isOpaque(ctx: CjbindContext, _: Unit): Bool {
        match (this.asType()) {
            case Some(v) => return v.isOpaque(ctx, this)
            case _ => return false
        }
    }

    // cjlint-ignore -start !G.FUN.01
    public static func parse(
        cursor: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): Result<ItemId, ParseError> {
        if (!cursor.isValid()) {
            return Result.Err(ParseError.Continue)
        }

        let comment = cursor.rawComment()
        let relevantParentId = parentId ?? ctx.currentModule

        match (Function.parse(cursor, ctx)) {
            case Ok(ParseResult.New(item, decl)) =>
                let nid = ctx.nextItemId()

                ctx.addItem(
                    Item(
                        nid,
                        comment,
                        relevantParentId,
                        ItemKind.KindFunction(item),
                        Some(cursor.location())
                    ),
                    decl,
                    Some(cursor)
                )

                return Ok(nid)
            case Ok(ParseResult.AlreadyResolved(nid)) => return Ok(nid)
            case Err(ParseError.Recurse) => return Err(ParseError.Recurse)
            case Err(ParseError.Continue) => ()
        }

        match (Var.parse(cursor, ctx)) {
            case Ok(ParseResult.New(item, decl)) =>
                let nid = ctx.nextItemId()

                ctx.addItem(
                    Item(
                        nid,
                        comment,
                        relevantParentId,
                        ItemKind.KindVar(item),
                        Some(cursor.location())
                    ),
                    decl,
                    Some(cursor)
                )

                return Ok(nid)
            case Ok(ParseResult.AlreadyResolved(nid)) => return Ok(nid)
            case Err(ParseError.Recurse) => return Err(ParseError.Recurse)
            case Err(ParseError.Continue) => ()
        }

        // handling types

        let definition = cursor.definition()
        let applicaleCursor = definition ?? cursor

        let tyRelevantParentId = match (definition) {
            case Some(def) =>
                if (def != cursor) {
                    ctx.addSemanticParent(def, relevantParentId)
                    return Result.Ok(
                        Item.fromTyOrRef(
                            applicaleCursor.curType(),
                            cursor,
                            parentId,
                            ctx
                        )
                    )
                }
                var p = ctx.knownSemanticParent(def)
                if (p.isNone()) {
                    p = parentId
                }
                p.getOrDefault {=> ctx.currentModule}
            case None => relevantParentId
        }

        match (Item.fromTy(
            applicaleCursor.curType(),
            applicaleCursor,
            Some(tyRelevantParentId),
            ctx
        )) {
            case Ok(tty) => return Ok(tty)
            case Err(ParseError.Recurse) => return Err(ParseError.Recurse)
            case Err(ParseError.Continue) => ()
        }

        let k = cursor.kind()

        if (k == clang.CXCursor_LinkageSpec || k == clang.CXCursor_UnexposedDecl) {
            return Err(ParseError.Recurse)
        } else if (k == clang.CXCursor_InclusionDirective) {
            let file = cursor.getIncludedFileName()
            match (file) {
                case None => () // we can do nothing with this
                case Some(includedFile) => ctx.addDep(includedFile)
            }
            return Err(ParseError.Continue)
        } else {
            // we don't care about these
            return Err(ParseError.Continue)
        }
    }
    // cjlint-ignore -end

    public static func newOpaqueType(
        withId: ItemId,
        ty: clang.Type,
        ctx: CjbindContext
    ): TypeId {
        let loc = ty.declaration().location()
        let tyOwn = Opaque.fromClangTy(ty, ctx)
        let ki = ItemKind.KindType(tyOwn)
        let parent = ctx.rootModule
        ctx.addItem(
            Item(withId, None, parent, ki, loc),
            None,
            None
        )
        return withId
    }

    public static func fromTyOrRef(
        ty: clang.Type,
        location: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): TypeId {
        let nid = ctx.nextItemId()
        return Item.fromTyOrRefWithId(nid, ty, location, parentId, ctx)
    }

    public static func fromTyOrRefWithId(
        potentialId: ItemId,
        ty: clang.Type,
        location: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): TypeId {
        if (ctx.collectedTyperefs) {
            return Item
                .fromTyWithId(
                    potentialId,
                    ty,
                    location,
                    parentId,
                    ctx
                )
                .unwrapOrElse {
                    _ => Item.newOpaqueType(potentialId, ty, ctx)
                }
        }

        if (let Some(tty) <- ctx.builtinOrResolvedTy(
            potentialId,
            parentId,
            ty,
            Some(location)
        )) {
            return tty
        }

        let isConst = ty.isConst()
        let _kind = TypeKind.UnresolvedTypeRef(ty, location, parentId)
        let pid = parentId ?? ctx.rootModule

        ctx.addItem(
            Item(
                potentialId,
                None,
                pid,
                ItemKind.KindType(Type(None, None, _kind, isConst)),
                None
            ),
            None,
            None
        )

        return potentialId
    }

    public static func fromTy(
        ty: clang.Type,
        location: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): Result<TypeId, ParseError> {
        let nid = ctx.nextItemId()
        return Item.fromTyWithId(nid, ty, location, parentId, ctx)
    }

    // cjlint-ignore -start !G.FUN.01
    public static func fromTyWithId(
        id: ItemId,
        ty: clang.Type,
        location: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): Result<TypeId, ParseError> {
        if (let Some(par) <- ty.declaration().fallibleSemanticParent()) {
            if (FunctionKind.fromCursor(par).isSome()) {
                return Ok(Item.newOpaqueType(id, ty, ctx))
            }
        }

        let decl: clang.Cursor = {
            =>
            let canDef = ty.canonicalType().declaration().definition()
            match (canDef) {
                case Some(v) => return v
                case None => ty.declaration()
            }
        }()

        let comment: ?String = {
            =>
            if (let Some(v) <- location.rawComment()) {
                return v
            }
            if (let Some(v) <- decl.rawComment()) {
                return v
            }
            if (let Some(v) <- location.rawComment()) {
                return v
            }
            return None<String>
        }()

        if (let Some(rty) <- ctx.builtinOrResolvedTy(id, parentId, ty, location)) {
            return Ok(rty)
        }

        var validDecl = decl.kind() != clang.CXCursor_NoDeclFound
        let nxtDecl = if (validDecl) {
            decl.canonical()
        } else {
            decl
        }

        if (validDecl) {
            var dup: Option<TypeId> = None
            for (t in ctx.currentlyParsedTypes) {
                if (t.decl == nxtDecl) {
                    dup = Some(t.id)
                    break
                }
            }

            if (let Some(v) <- dup) {
                return Ok(v)
            }
        }

        if (validDecl) {
            ctx.beginParsing(PartialType(nxtDecl, id))
        }

        let result = Type.fromClangTy(id, ty, location, parentId, ctx)
        let relevantParentId = parentId ?? ctx.currentModule

        let ret: Result<TypeId, ParseError> = match (result) {
            case Ok(ParseResult.AlreadyResolved(ty)) => Ok(ty)
            case Ok(ParseResult.New(titem, tdecl)) =>
                ctx.addItem(
                    Item(
                        id,
                        comment,
                        relevantParentId,
                        ItemKind.KindType(titem),
                        Some(location.location())
                    ),
                    tdecl,
                    Some(location)
                )
                Ok(id)
            case Err(ParseError.Continue) => Err(ParseError.Continue)
            case Err(ParseError.Recurse) =>
                let result2 = Box(Result<TypeId, ParseError>.Err(ParseError.Recurse))
                if (validDecl) {
                    let finished = ctx.finishParsing()
                    if (finished.decl != nxtDecl) {
                        throw Exception("finished.decl != nxtDecl")
                    }
                }

                location.visit {
                    cur => visitChild(cur, id, ty, parentId, ctx, result2)
                }

                if (validDecl) {
                    ctx.beginParsing(PartialType(nxtDecl, id))
                }

                if (let Err(ParseError.Recurse) <- result2.value) {
                    throw Exception("unreachable")
                } else {
                    result2.value
                }
        }

        if (validDecl) {
            let pty = ctx.finishParsing()
            if (!(pty.decl == nxtDecl)) {
                throw Exception("pty.decl != nxtDecl")
            }
        }

        return ret
    }
    // cjlint-ignore -end
}

// cjlint-ignore -start !G.FUN.01
func visitChild(
    cur: clang.Cursor,
    id: ItemId,
    ty: clang.Type,
    parentId: ?ItemId,
    ctx: CjbindContext,
    result: Box<Result<TypeId, ParseError>>
): clang.CXChildVisitResult {
    if (result.value.isOk()) {
        return clang.CXChildVisit_Break
    }

    result.value = Item.fromTyWithId(id, ty, cur, parentId, ctx)

    return match (result.value) {
        case Ok(_) => clang.CXChildVisit_Break
        case Err(ParseError.Recurse) =>
            cur.visit {
                c => visitChild(c, id, ty, parentId, ctx, result)
            }
            clang.CXChildVisit_Continue
        case Err(ParseError.Continue) => clang.CXChildVisit_Continue
    }
}
// cjlint-ignore -end
