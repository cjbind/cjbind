package cjbind.ir

import cjbind.clang
import cjbind.result.Result

public class Type {
    public let name: ?String
    public let layout: ?Layout
    public let kind: TypeKind
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
        let name: ?String = if (isAnonymous) {
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

        if (tyKind == clang.CXType_Unexposed && ty != canonicalTy && canonicalTy.kind() != clang.CXType_Invalid && ty.retType().isNone()) {
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
                match(sigR) {
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
            let inner = Item.fromTy(
                ty.elemType().getOrThrow(),
                location,
                None,
                ctx
            ).expect("Not able to resolve array element")
            TypeKind.TypeKindPointer(inner)
        } else if (tyKind == clang.CXType_IncompleteArray) {
            let inner = Item.fromTy(
                ty.elemType().getOrThrow(),
                location,
                None,
                ctx
            ).expect("Not able to resolve array element")
            TypeKind.TypeKindArray(inner, 0)
        } else if (tyKind == clang.CXType_FunctionProto || 
            tyKind == clang.CXType_FunctionNoProto) {
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
        } else {
            
        }
        

        throw Exception()
    }
    // cjlint-ignore -end
}

public enum TypeKind {
    TypeKindVoid |
    TypeKindNullPtr |
    TypeKindComp(CompInfo) |
    TypeKindOpaque |
    TypeKindInt(TypeKindIntKind) |
    TypeKindFloat(TypeKindFloatKind) |
    TypeKindComplex(TypeKindFloatKind) |
    TypeKindAlias(TypeId) |
    TypeKindVector(TypeId, UIntNative) |
    TypeKindArray(TypeId, UIntNative) |
    TypeKindFunction(FunctionSig) |
    TypeKindEnum(TypeKindEnumKind) |
    TypeKindPointer(TypeId) |
    UnresolvedTypeRef(clang.Type, clang.Cursor, ?ItemId) |
    ResolvedTypeRef(TypeId)
}