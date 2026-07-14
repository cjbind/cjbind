package cjbind.ir

import std.collection.{ArrayList, HashSet, contains}
import cjbind.clang
import cjbind.result.Result

public type ItemSet = HashSet<ItemId>

public interface IsOpaque<Extra> {
    func isOpaque(ctx: CjbindContext, extra: Extra): Bool
}

public class ItemAncestorsIter <: Iterator<ItemId> {
    var currentId: ItemId
    let ctx: CjbindContext

    public init(ctx: CjbindContext, startId: ItemId) {
        this.ctx = ctx
        this.currentId = startId
    }

    public func next(): Option<ItemId> {
        let item = this.ctx.resolveItemFallible(this.currentId)
        match (item) {
            case Some(it) =>
                if (this.currentId == it.parentId) {
                    return None
                }
                let oldId = this.currentId
                this.currentId = it.parentId
                return Some(oldId)
            case None => return None
        }
    }
}

public class Item <: Trace<Tracer, Unit> & IsOpaque<Unit> {
    public let id: ItemId
    var localId: ?ItemId
    var nextChildLocalId: ItemId
    var canonicalNameCache: ?String
    public let comment: ?String
    public let annotations: Annotations
    public let parentId: ItemId
    public var kind: ItemKind
    public let location: ?clang.SourceLocation

    public init(
        id: ItemId,
        comment: ?String,
        parentId: ItemId,
        kind: ItemKind,
        location: ?clang.SourceLocation,
        annotations!: Annotations = Annotations()
    ) {
        if (!(id != parentId || kind.isModule())) {
            throw Exception("item error")
        }

        this.id = id
        this.localId = None
        this.nextChildLocalId = 1
        this.canonicalNameCache = None
        this.parentId = parentId
        this.comment = comment
        this.annotations = annotations
        this.kind = kind
        this.location = location
    }

    public static func builtinType(nkd: TypeKind, isConst: Bool, ctx: CjbindContext): TypeId {
        match (nkd) {
            case TypeKind.TypeKindVoid => ()
            case TypeKind.TypeKindInt(_) => ()
            case TypeKind.TypeKindFloat(_) => ()
            case TypeKind.TypeKindPointer(_) => ()
            case _ => throw Exception("Unexpected builtin type kind")
        }

        let ty = Type(None, None, nkd, isConst)
        let nid = ctx.nextItemId()
        let module = ctx.rootModule
        ctx.addItem(
            Item(nid, None, module, ItemKind.KindType(ty), None),
            None,
            None
        )
        return nid
    }

    public func getNextChildLocalId(): ItemId {
        let v = this.nextChildLocalId
        this.nextChildLocalId += 1
        return v
    }

    public func getLocalId(ctx: CjbindContext): ItemId {
        if (let Some(v) <- localId) {
            return v
        }

        let parent = ctx.resolveItem(this.parentId)
        let v = parent.getNextChildLocalId()
        this.localId = Some(v)
        return v
    }

    public func exposedId(ctx: CjbindContext): String {
        let tyKind = this.kind.asType().map {
            t => t.kind
        }

        let useLocal = match (tyKind) {
            case Some(TypeKind.TypeKindComp(_)) | Some(TypeKind.TypeKindEnum(_)) => true
            case _ => false
        }

        if (useLocal) {
            return this.getLocalId(ctx).toString()
        } else {
            return "id_${this.id}"
        }
    }

    public func baseName(ctx: CjbindContext): String {
        match (this.kind) {
            case ItemKind.KindVar(v) => v.name
            case ItemKind.KindModule(module) => module.name.getOrDefault {
                => "_cjbind_mod_${this.exposedId(ctx)}"
            }
            case ItemKind.KindType(ty) =>
                if (ctx.usedTemplateParameters.isSome()) {
                    if (let Some(instantiation) <- ctx.templateInstantiationFor(this.id)) {
                        return templateInstantiationName(ctx.publicTemplateInstantiationSpelling(instantiation))
                    }
                }
                ty.sanitizedName(ctx).getOrDefault {=> "_cjbind_ty_${this.exposedId(ctx)}"}
            case ItemKind.KindFunction(fun) => fun.name
        }
    }

    func policyBaseName(ctx: CjbindContext): String {
        let base = this.baseName(ctx)
        let function = match (this.kind) {
            case ItemKind.KindFunction(value) => value
            case _ => return base
        }
        let parent = this.parentId
        if (parent == ctx.rootModule) {
            return base
        }
        let comp: ?CompInfo = match (ctx.resolveItem(parent).kind.asType()) {
            case Some(parentType) => parentType.asComp()
            case None => None
        }
        match (comp) {
            case Some(value) =>
                let overloadIndex: ?Int64 = match (function.kind) {
                    case FunctionKind.KindMethod(MethodKind.Constructor) =>
                        var found: ?Int64 = None
                        for ((index, constructor) in value.constructors.iterator().enumerate()) {
                            if (constructor == this.id) {
                                found = Some(index)
                                break
                            }
                        }
                        found
                    case FunctionKind.KindMethod(MethodKind.Normal) |
                        FunctionKind.KindMethod(MethodKind.Static) |
                        FunctionKind.KindMethod(MethodKind.Virtual(_)) =>
                        var matchingIndex = 0
                        var found: ?Int64 = None
                        for (method in value.methods) {
                            let methodItem = ctx.resolveItem(method.signature)
                            let methodName = methodItem.kind.expectFunction().name
                            if (methodName != function.name) {
                                continue
                            }
                            if (method.signature == this.id) {
                                found = Some(matchingIndex)
                                break
                            }
                            matchingIndex += 1
                        }
                        found
                    case _ => None
                }
                match (overloadIndex) {
                    case Some(index) where index > 0 => "${base}${index}"
                    case _ => base
                }
            case None => base
        }
    }

    func policyNameTarget(ctx: CjbindContext): Item {
        var target = this
        let visited = ItemSet()
        while (!visited.contains(target.id)) {
            visited.add(target.id)
            let next: ?ItemId = match (target.kind) {
                case ItemKind.KindType(ty) => match (ty.kind) {
                    case TypeKind.ResolvedTypeRef(inner) => Some(inner)
                    case TypeKind.TypeKindTemplateInstantiation(instantiation) => Some(instantiation.definition)
                    case _ => ctx.templateInstantiationFor(target.id).map({value => value.definition})
                }
                case _ => None
            }
            match (next) {
                case Some(id) => target = ctx.resolveItem(id)
                case None => return target
            }
        }
        return target
    }

    public func policyName(ctx: CjbindContext): String {
        let target = this.policyNameTarget(ctx)
        let namespaces = ArrayList<String>()
        let nested = ArrayList<String>()
        var parent = target.parentId
        while (parent != ctx.rootModule) {
            let ancestor = ctx.resolveItem(parent)
            match (ancestor.kind) {
                case ItemKind.KindModule(module) =>
                    if (ctx.options.conservativeInlineNamespaces || !module.isInline()) {
                        let name = ancestor.policyBaseName(ctx)
                        if (!name.isEmpty()) {
                            namespaces.add(name)
                        }
                    }
                case _ =>
                    let name = ancestor.policyBaseName(ctx)
                    if (!name.isEmpty()) {
                        nested.add(name)
                    }
            }
            parent = ancestor.parentId
        }
        namespaces.reverse()
        nested.reverse()
        let targetName = target.policyBaseName(ctx)
        if (!targetName.isEmpty()) {
            nested.add(targetName)
        }
        if (!nested.isEmpty()) {
            namespaces.add(String.join(nested.toArray(), delimiter: "_"))
        }
        return String.join(namespaces.toArray(), delimiter: "::")
    }

    public func isAnon(): Bool {
        match (this.kind) {
            case ItemKind.KindModule(module) => module.name.isNone()
            case ItemKind.KindType(ty) => ty.name.isNone()
            case ItemKind.KindFunction(_) => false
            case ItemKind.KindVar(_) => false
        }
    }

    public func ancestors(ctx: CjbindContext): ItemAncestorsIter {
        return ItemAncestorsIter(ctx, this.id)
    }

    public func canonicalName(ctx: CjbindContext): String {
        if (ctx.usedTemplateParameters.isSome()) {
            return this.realCanonicalName(ctx)
        }
        if (let Some(cached) <- this.canonicalNameCache) {
            return cached
        }

        let result = this.realCanonicalName(ctx)
        this.canonicalNameCache = Some(result)
        return result
    }

    func realCanonicalName(ctx: CjbindContext): String {
        let baseName = this.baseName(ctx)

        let ancestorIds = ArrayList<ItemId>()
        for (id in this.ancestors(ctx)) {
            if (id != ctx.rootModule) {
                ancestorIds.add(id)
            }
        }

        var names = ArrayList<String>()
        for (id in ancestorIds) {
            let item = ctx.resolveItem(id)
            if (ctx.options.enableCxxNamespaces && !ctx.options.conservativeInlineNamespaces &&
                item.asModule().map({module => module.isInline()}).getOrDefault({=> false})) {
                continue
            }
            let name = item.baseName(ctx)
            var shouldAddName = !name.startsWith("_cjbind_")
            if (!shouldAddName && item.kind.isType()) {
                shouldAddName = name.startsWith("_cjbind_ty_")
            }
            if (!name.isEmpty() && shouldAddName) {
                names.add(name)
            }
        }

        names.reverse()

        if (!baseName.isEmpty()) {
            names.add(baseName)
        }

        return String.join(names.toArray(), delimiter: "_")
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
    public func trace(ctx: CjbindContext, tracer: Tracer, _: Unit): Unit {
        if (let Some(instantiation) <- ctx.concreteTemplateInstantiations.get(this.id)) {
            instantiation.trace(ctx, tracer, ())
        }
        match (this.kind) {
            case ItemKind.KindType(ty) =>
                if (ty.shouldBeTracedUnconditionally() || !this.isOpaque(ctx, ())) {
                    ty.trace(ctx, tracer, this)
                }
            case ItemKind.KindFunction(fun) => tracer.visit(fun.signature)
            case ItemKind.KindVar(v) => tracer.visitKind(v.ty, EdgeKind.VarTypeEdge)
            case ItemKind.KindModule(_) => ()
        }
    }
    // cjlint-ignore -end

    public func isOpaque(ctx: CjbindContext, _: Unit): Bool {
        if (this.annotations.opaque() || ctx.isOpaqueByName(this)) {
            return true
        }
        match (this.asType()) {
            case Some(v) => return v.isOpaque(ctx, this)
            case _ => return false
        }
    }

    public func isSemanticallyOpaque(ctx: CjbindContext): Bool {
        if (this.annotations.opaque() || ctx.isOpaqueByName(this)) {
            return true
        }
        return match (this.asType()) {
            case Some(value) => value.isSemanticallyOpaque(ctx, this)
            case None => false
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

        if (k == clang.CXCursorKind_CXCursor_LinkageSpec || k == clang.CXCursorKind_CXCursor_UnexposedDecl) {
            return Err(ParseError.Recurse)
        } else if (k == clang.CXCursorKind_CXCursor_InclusionDirective) {
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

    public static func typeParam(
        withId: ?ItemId,
        location: clang.Cursor,
        ctx: CjbindContext,
        ty: clang.Type
    ): ?TypeId {
        if (ty.kind() != clang.CXTypeKind_CXType_Unexposed &&
            ty.kind() != clang.CXTypeKind_CXType_Elaborated &&
            ty.kind() != clang.CXTypeKind_CXType_Dependent &&
            location.kind() != clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
            return None
        }
        let definition: Box<?clang.Cursor> = Box(None)
        if (location.kind() == clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
            definition.value = Some(location.canonical())
        } else if (location.kind() == clang.CXCursorKind_CXCursor_TypeRef) {
            if (let Some(referenced) <- location.referenced()) {
                if (referenced.kind() == clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
                    definition.value = Some(referenced.canonical())
                }
            }
        } else {
            let typeDeclaration = ty.declaration()
            if (typeDeclaration.kind() == clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
                definition.value = Some(typeDeclaration.canonical())
            }
        }

        let definitionCursor = match (definition.value) {
            case Some(value) => value
            case None => return None
        }
        if (let Some(existing) <- ctx.typeParams.get(definitionCursor)) {
            if (let Some(id) <- withId) {
                return Some(ctx.buildTyWrapper(id, existing, Some(ctx.rootModule), ty))
            }
            return Some(existing)
        }

        var name = definitionCursor.spelling()
        if (name.isEmpty()) {
            name = ty.spelling().replace("const ", "").replace(".", "")
        }
        let id = withId ?? ctx.nextItemId()
        let item = Item(
            id,
            None,
            ctx.rootModule,
            ItemKind.KindType(Type(Some(name), None, TypeKind.TypeKindTypeParam, false)),
            Some(location.location())
        )
        ctx.typeParams.add(definitionCursor, id)
        ctx.addItem(item, Some(definitionCursor), Some(location))
        return Some(id)
    }

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
        let kind = TypeKind.UnresolvedTypeRef(ty, location, parentId)
        let pid = parentId ?? ctx.rootModule

        ctx.addItem(
            Item(
                potentialId,
                None,
                pid,
                ItemKind.KindType(Type(None, None, kind, isConst)),
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
        let locationKind = location.kind()
        let canBeTypeParameter = locationKind != clang.CXCursorKind_CXCursor_ClassTemplate &&
            locationKind != clang.CXCursorKind_CXCursor_ClassTemplatePartialSpecialization &&
            locationKind != clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl
        let tyKind = ty.kind()
        let typeMayBeParameter = tyKind == clang.CXTypeKind_CXType_Unexposed ||
            tyKind == clang.CXTypeKind_CXType_Elaborated ||
            tyKind == clang.CXTypeKind_CXType_Dependent
        let locationTypeKind = if (typeMayBeParameter) {
            clang.CXTypeKind_CXType_Invalid
        } else {
            location.curType().kind()
        }
        if (canBeTypeParameter &&
            (typeMayBeParameter ||
            locationTypeKind == clang.CXTypeKind_CXType_Unexposed ||
            locationTypeKind == clang.CXTypeKind_CXType_Elaborated ||
            locationTypeKind == clang.CXTypeKind_CXType_Dependent)) {
            if (let Some(param) <- Item.typeParam(Some(id), location, ctx, ty)) {
                return Ok(param)
            }
        }

        if (tyKind == clang.CXTypeKind_CXType_Elaborated) {
            let namedType = ty.named()
            if (namedType != ty) {
                return Item.fromTyWithId(id, namedType, location, parentId, ctx)
            }
            return Err(ParseError.Continue)
        }

        if (let Some(par) <- ty.declaration().fallibleSemanticParent()) {
            if (FunctionKind.fromCursor(par).isSome()) {
                return Ok(Item.newOpaqueType(id, ty, ctx))
            }
        }
        let decl: clang.Cursor = {
            =>
            let directDeclaration = ty.declaration()
            if (let Some(directDefinition) <- directDeclaration.definition()) {
                return directDefinition
            }
            if (tyKind == clang.CXTypeKind_CXType_Unexposed ||
                tyKind == clang.CXTypeKind_CXType_Elaborated ||
                tyKind == clang.CXTypeKind_CXType_Dependent) {
                return directDeclaration
            }
            let canDef = ty.canonicalType().declaration().definition()
            match (canDef) {
                case Some(v) => return v
                case None => directDeclaration
            }
        }()

        let carriesTypeAnnotations = locationKind == clang.CXCursorKind_CXCursor_StructDecl ||
            locationKind == clang.CXCursorKind_CXCursor_UnionDecl ||
            locationKind == clang.CXCursorKind_CXCursor_ClassDecl ||
            locationKind == clang.CXCursorKind_CXCursor_ClassTemplate ||
            locationKind == clang.CXCursorKind_CXCursor_ClassTemplatePartialSpecialization ||
            locationKind == clang.CXCursorKind_CXCursor_EnumDecl
        let comment: ?String = if (carriesTypeAnnotations) {
            match (location.rawComment()) {
                case Some(value) => Some(value)
                case None => decl.rawComment()
            }
        } else {
            None
        }
        let annotations = if (carriesTypeAnnotations) {
            match (parseAnnotations(decl.comment())) {
                case Some(value) => value
                case None => parseAnnotations(location.comment()).getOrDefault({=> Annotations()})
            }
        } else {
            Annotations()
        }
        if (let Some(rty) <- ctx.builtinOrResolvedTy(id, parentId, ty, location)) {
            return Ok(rty)
        }

        var validDecl = decl.kind() != clang.CXCursorKind_CXCursor_NoDeclFound
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
                let sourceLocation = location.location()
                ctx.addItem(
                    Item(
                        id,
                        comment,
                        relevantParentId,
                        ItemKind.KindType(titem),
                        Some(sourceLocation),
                        annotations: annotations
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
                    result2.value = Result<TypeId, ParseError>.Err(ParseError.Continue)
                }
                result2.value
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
        return clang.CXChildVisitResult_CXChildVisit_Break
    }

    result.value = Item.fromTyWithId(id, ty, cur, parentId, ctx)

    return match (result.value) {
        case Ok(_) => clang.CXChildVisitResult_CXChildVisit_Break
        case Err(ParseError.Recurse) => clang.CXChildVisitResult_CXChildVisit_Recurse
        case Err(ParseError.Continue) => clang.CXChildVisitResult_CXChildVisit_Continue
    }
}
// cjlint-ignore -end
