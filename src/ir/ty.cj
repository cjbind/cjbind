package cjbind.ir

import cjbind.clang
import cjbind.result.Result

public class Type <: IsOpaque<Item> & Trace<Tracer, Item> {
    public let name: ?String
    let layout: ?Layout
    public var kind: TypeKind
    public let isConst: Bool

    public init(
        name: ?String,
        layout: ?Layout,
        kind: TypeKind,
        isConst: Bool
    ) {
        this.name = name
        this.layout = layout
        this.kind = kind
        this.isConst = isConst
    }

    public func isInt(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindInt(_) => true
            case _ => false
        }
    }

    public func asInt(): ?TypeKindIntKind {
        match (this.kind) {
            case TypeKind.TypeKindInt(v) => v
            case _ => None
        }
    }

    public func isComp(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindComp(_) => true
            case _ => false
        }
    }

    public func isUnion(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindComp(info) => info.isUnion()
            case _ => false
        }
    }

    public func isFunction(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindFunction(_) => true
            case _ => false
        }
    }

    public func safeCanonicalType(ctx: CjbindContext): ?Type {
        match (this.kind) {
            case TypeKind.ResolvedTypeRef(inner) => ctx.resolveType(inner).safeCanonicalType(ctx)
            case TypeKind.TypeKindAlias(inner) => ctx.resolveType(inner).safeCanonicalType(ctx)
            case TypeKind.UnresolvedTypeRef(_, _, _) => None
            case _ => Some(this)
        }
    }

    public func canonicalType(ctx: CjbindContext): Type {
        return this.safeCanonicalType(ctx).getOrThrow()
    }

    public func isFloat(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindFloat(_) => true
            case _ => false
        }
    }

    public func isBool(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindInt(IntKindBool) => true
            case _ => false
        }
    }

    public func isInteger(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindInt(_) => true
            case _ => false
        }
    }

    public func isEnum(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindEnum(_) => true
            case _ => false
        }
    }

    // cjlint-ignore -start !G.FUN.01
    public static func fromClangTy(
        potentialId: ItemId,
        ty: clang.Type,
        location: clang.Cursor,
        parentId: ?ItemId,
        ctx: CjbindContext
    ): Result<ParseResult<Type>, ParseError> {
        let alreadyResolved = ctx.builtinOrResolvedTy(
            potentialId,
            parentId,
            ty,
            Some(location)
        )
        if (let Some(tty) <- alreadyResolved) {
            return Result.Ok(ParseResult.AlreadyResolved(tty))
        }

        let layout = ty.fallibleLayout(ctx).ok()
        let cursor = ty.declaration()
        let isAnonymous = cursor.isAnonymous()
        var name: ?String = if (isAnonymous) {
            None
        } else {
            let sp = cursor.spelling()
            if (sp.isEmpty()) {
                None
            } else {
                Some(sp)
            }
        }

        let canonicalTy = ty.canonicalType()
        let tyKind = ty.kind()

        if (tyKind == clang.CXType_Unexposed && ty != canonicalTy && canonicalTy.kind() != clang.CXType_Invalid &&
            ty.retType().isNone()) {
            return Type.fromClangTy(
                potentialId,
                canonicalTy,
                location,
                parentId,
                ctx
            )
        }

        let tkind = if (tyKind == clang.CXType_Unexposed || tyKind == clang.CXType_Invalid) {
            if (ty.retType().isSome()) {
                let sigR = FunctionSig.fromTy(ty, location, ctx)
                match (sigR) {
                    case Ok(v) => TypeKind.TypeKindFunction(v)
                    case Err(e) => return Err(e)
                }
            } else {
                let lk = location.kind()
                if (lk == clang.CXCursor_TypeRef) {
                    let referenced = location.referenced().getOrThrow()
                    let referencedTy = referenced.curType()
                    let decl = referencedTy.declaration()

                    let id = Item.fromTyOrRefWithId(
                        potentialId,
                        referencedTy,
                        decl,
                        parentId,
                        ctx
                    )
                    return Ok(ParseResult.AlreadyResolved(id))
                } else {
                    if (ty.kind() == clang.CXType_Unexposed) {
                        return Err(ParseError.Recurse)
                    } else {
                        return Err(ParseError.Continue)
                    }
                }
            }
        } else if (tyKind == clang.CXType_Auto) {
            if (canonicalTy == ty) {
                return Err(ParseError.Continue)
            }

            return Type.fromClangTy(
                potentialId,
                canonicalTy,
                location,
                parentId,
                ctx
            )
        } else if (tyKind == clang.CXType_Pointer) {
            var pointee = ty.pointeeType().getOrThrow()
            if (ty != canonicalTy) {
                let canonicalPointee = canonicalTy.pointeeType().getOrThrow()
                if (canonicalPointee.isConst() != pointee.isConst()) {
                    pointee = canonicalPointee
                }
            }
            let inner = Item.fromTyOrRef(pointee, location, None, ctx)
            TypeKind.TypeKindPointer(inner)
        } else if (tyKind == clang.CXType_VariableArray) {
            let inner = Item
                .fromTy(
                    ty.elemType().getOrThrow(),
                    location,
                    None,
                    ctx
                )
                .expect("Not able to resolve array element")
            TypeKind.TypeKindPointer(inner)
        } else if (tyKind == clang.CXType_IncompleteArray) {
            let inner = Item
                .fromTy(
                    ty.elemType().getOrThrow(),
                    location,
                    None,
                    ctx
                )
                .expect("Not able to resolve array element")
            TypeKind.TypeKindArray(inner, 0)
        } else if (tyKind == clang.CXType_FunctionProto || tyKind == clang.CXType_FunctionNoProto) {
            let sig = FunctionSig.fromTy(ty, location, ctx)
            match (sig) {
                case Ok(v) => TypeKind.TypeKindFunction(v)
                case Err(e) => return Err(e)
            }
        } else if (tyKind == clang.CXType_Typedef) {
            let inner = cursor.typedefType().getOrThrow()
            let innerId = Item.fromTyOrRef(inner, location, None, ctx)
            if (innerId == potentialId) {
                TypeKind.TypeKindOpaque
            } else {
                TypeKind.TypeKindAlias(innerId)
            }
        } else if (tyKind == clang.CXType_Enum) {
            let enum_ = Enum.fromTy(ty, ctx).expect("Not an enum?")

            if (!isAnonymous) {
                let prettyName = ty.spelling()
                if (clang.isValidIdentifier(prettyName)) {
                    name = Some(prettyName)
                }
            }

            TypeKind.TypeKindEnum(enum_)
        } else if (tyKind == clang.CXType_Record) {
            let complex = CompInfo.fromTy(potentialId, ty, location, ctx).expect("Not a complex")
            if (!isAnonymous) {
                let prettyName = ty.spelling()
                if (clang.isValidIdentifier(prettyName)) {
                    name = Some(prettyName)
                }
            }

            TypeKind.TypeKindComp(complex)
        } else if (tyKind == clang.CXType_Vector) {
            let innerr = Item.fromTy(
                ty.elemType().getOrThrow(),
                location,
                None,
                ctx
            )
            let inner = match (innerr) {
                case Ok(v) => v
                case Err(e) => return Err(e)
            }

            TypeKind.TypeKindVector(inner, ty.numElements().getOrThrow())
        } else if (tyKind == clang.CXType_ConstantArray) {
            let inner = Item
                .fromTy(
                    ty.elemType().getOrThrow(),
                    location,
                    None,
                    ctx
                )
                .expect("Not able to resolve array element")

            TypeKind.TypeKindArray(inner, ty.numElements().getOrThrow())
        } else if (tyKind == clang.CXType_Atomic) {
            return Type.fromClangTy(
                potentialId,
                ty.atomicValueType(),
                location,
                parentId,
                ctx
            )
        } else if (tyKind == clang.CXType_Elaborated) {
            return Type.fromClangTy(
                potentialId,
                ty.named(),
                location,
                parentId,
                ctx
            )
        } else if (tyKind == clang.CXType_Dependent) {
            return Err(ParseError.Continue)
        } else {
            // unsupported
            return Err(ParseError.Continue)
        }

        name = name.filter {
            n => !n.isEmpty()
        }

        let isConst2 = ty.isConst() || (ty.kind() == clang.CXType_ConstantArray && (ty
            .elemType()
            .flatMap {
                ele => ele.isConst()
            }
            .getOrDefault {=> false}))

        let tty = Type(name, layout, tkind, isConst2)

        return Result.Ok(ParseResult.New(tty, Some(cursor.canonical())))
    }
    // cjlint-ignore -end

    public func getLayout(ctx: CjbindContext): ?Layout {
        match (this.layout) {
            case Some(v) => return v
            case _ => ()
        }

        return match (this.kind) {
            case TypeKind.TypeKindComp(ci) => ci.getLayout(ctx)
            case TypeKind.TypeKindArray(inner, _) =>
                let innerLayout = ctx.resolveType(inner).getLayout(ctx)
                match (innerLayout) {
                    case Some(v) => Some(Layout(0, v.align))
                    case None => None
                }
            case TypeKind.ResolvedTypeRef(inner) => ctx.resolveType(inner).getLayout(ctx)
            case _ => None
        }
    }

    public func asComp(): ?CompInfo {
        match (this.kind) {
            case TypeKind.TypeKindComp(ci) => ci
            case _ => None
        }
    }

    public func shouldBeTracedUnconditionally(): Bool {
        match (this.kind) {
            case TypeKind.TypeKindComp(_) |
                TypeKind.TypeKindFunction(_) |
                TypeKind.TypeKindPointer(_) |
                TypeKind.TypeKindArray(_, _) |
                TypeKind.ResolvedTypeRef(_) => true
            case _ => false
        }
    }

    public func sanitizedName(ctx: CjbindContext): ?String {
        let nameInfo: ?(ItemId, String) = match (this.kind) {
            case TypeKind.TypeKindPointer(inner) => Some((inner, "ptr"))
            case TypeKind.TypeKindArray(inner, length) => Some((inner, "array${length}"))
            case _ => None
        }

        if (let Some((inner, prefix)) <- nameInfo) {
            return ctx.resolveItem(inner)
                .kind.expectType()
                .sanitizedName(ctx)
                .map {
                    n => "${prefix}_${n}"
                }
        } else {
            return this.name.map {
                n =>
                if (clang.isValidIdentifier(n)) {
                    return n
                }

                return n.replace(" ", "_").replace(":", "_").replace(".", "_")
            }
        }
    }

    public func isOpaque(ctx: CjbindContext, _: Item): Bool {
        return match (this.kind) {
            case TypeKind.TypeKindOpaque => true
            case TypeKind.TypeKindComp(comp) => comp.isOpaque(ctx, this.layout)
            case TypeKind.ResolvedTypeRef(to) => to.isOpaque(ctx, ())
            case _ => false
        }
    }

    public func isInCompleteArray(
        ctx: CjbindContext
    ): ?ItemId {
        match (this.kind) {
            case TypeKind.TypeKindArray(item, len) =>
                if (len == 0) {
                    return Some(item)
                } else {
                    return None
                }
            case TypeKind.ResolvedTypeRef(inner) =>
                return ctx.resolveType(inner).isInCompleteArray(ctx)
            case _ => return None
        }
    }

    // cjlint-ignore -start !G.ITF.04
    public func trace(context: CjbindContext, tracer: Tracer, item: Item) {
        if (let Some(n) <- this.name) {
            if (context.isStdintType(n)) {
                return
            }
        }

        match (this.kind) {
            case TypeKind.TypeKindPointer(inner) => 
                tracer.visitKind(inner, EdgeKind.TypeReferenceEdge)
            case TypeKind.TypeKindArray(inner, _) =>
                tracer.visitKind(inner, EdgeKind.TypeReferenceEdge)
            case TypeKind.TypeKindVector(inner, _) =>
                tracer.visitKind(inner, EdgeKind.TypeReferenceEdge)
            case TypeKind.TypeKindAlias(inner) =>
                tracer.visitKind(inner, EdgeKind.TypeReferenceEdge)
            case TypeKind.ResolvedTypeRef(inner) =>
                tracer.visitKind(inner, EdgeKind.TypeReferenceEdge)
            case TypeKind.TypeKindComp(ci) =>
                ci.trace(context, tracer, item)
            case TypeKind.TypeKindFunction(sig) =>
                sig.trace(context, tracer, ())
            case TypeKind.TypeKindEnum(en) => 
                if (let Some(r) <- en.repr) {
                    tracer.visit(r)
                }
            case TypeKind.UnresolvedTypeRef(_, _, Some(id)) =>
                tracer.visit(id)
            case _ => () // don't care
        }


    }
    // cjlint-ignore -end
}

public enum TypeKind {
    TypeKindVoid
    | TypeKindNullPtr
    | TypeKindComp(CompInfo)
    | TypeKindOpaque
    | TypeKindInt(TypeKindIntKind)
    | TypeKindFloat(TypeKindFloatKind)
    | TypeKindComplex(TypeKindFloatKind)
    | TypeKindAlias(TypeId)
    | TypeKindVector(TypeId, UIntNative)
    | TypeKindArray(TypeId, UIntNative)
    | TypeKindFunction(FunctionSig)
    | TypeKindEnum(Enum)
    | TypeKindPointer(TypeId)
    | UnresolvedTypeRef(clang.Type, clang.Cursor, ?ItemId)
    | ResolvedTypeRef(TypeId)
}
