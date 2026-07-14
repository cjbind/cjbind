package cjbind.ir

import std.collection.{ArrayList, collectArrayList}
import cjbind.clang

public func selfTemplateParams(id: ItemId, ctx: CjbindContext): Array<TypeId> {
    let item = match (ctx.resolveItemFallible(id)) {
        case Some(value) => value
        case None => return Array<TypeId>()
    }
    let ty = match (item.kind.asType()) {
        case Some(value) => value
        case None => return Array<TypeId>()
    }
    return match (ty.kind) {
        case TypeKind.TypeKindComp(comp) => comp.templateParams.toArray()
        case TypeKind.TypeKindTemplateAlias(_, parameters) => parameters
        case TypeKind.ResolvedTypeRef(inner) => selfTemplateParams(inner, ctx)
        case _ => Array<TypeId>()
    }
}

public func allTemplateParams(id: ItemId, ctx: CjbindContext): Array<TypeId> {
    let ancestors = id.ancestors(ctx) |> collectArrayList
    ancestors.reverse()
    let parameters = ArrayList<TypeId>()
    for (ancestor in ancestors) {
        parameters.add(all: selfTemplateParams(ancestor, ctx))
    }
    return parameters.toArray()
}

public class TemplateInstantiation <: Trace<Tracer, Unit> {
    public let definition: TypeId
    public let arguments: Array<TypeId>

    public init(definition: TypeId, arguments: Array<TypeId>) {
        this.definition = definition
        this.arguments = arguments
    }

    public static func fromTy(ty: clang.Type, ctx: CjbindContext): ?TemplateInstantiation {
        let arguments = ArrayList<TypeId>()
        if (let Some(directArguments) <- ty.templateArgs()) {
            for (argument in directArguments) {
                if (argument.isValid()) {
                    arguments.add(Item.fromTyOrRef(
                        argument,
                        argument.declaration(),
                        None,
                        ctx
                    ))
                }
            }
            if (let Some(canonicalArguments) <- ty.canonicalType().templateArgs()) {
                if (canonicalArguments.size > directArguments.size) {
                    for (index in directArguments.size..canonicalArguments.size) {
                        let argument = canonicalArguments[index]
                        if (argument.isValid()) {
                            arguments.add(Item.fromTyOrRef(
                                argument,
                                argument.declaration(),
                                None,
                                ctx
                            ))
                        }
                    }
                }
            }
        }

        let declaration = ty.declaration()
        var definition: ?clang.Cursor = if (declaration.kind() ==
            clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl) {
            Some(declaration)
        } else {
            declaration.specialized()
        }

        if (definition.isNone()) {
            let templateReference: Box<?clang.Cursor> = Box(None)
            declaration.visit {
                child =>
                if (child.kind() == clang.CXCursorKind_CXCursor_TemplateRef) {
                    templateReference.value = child.referenced()
                    return clang.CXChildVisitResult_CXChildVisit_Break
                }
                return clang.CXChildVisitResult_CXChildVisit_Recurse
            }
            definition = templateReference.value
        }

        let definitionCursor = match (definition) {
            case Some(value) => value
            case None =>
                if (!declaration.isBuiltin()) {
                    eprintln("Warning: unable to find the definition of a C++ template instantiation")
                }
                return None
        }
        let templateDefinition = Item.fromTyOrRef(
            definitionCursor.curType(),
            definitionCursor,
            None,
            ctx
        )
        return Some(TemplateInstantiation(templateDefinition, arguments.toArray()))
    }

    public func trace(_: CjbindContext, tracer: Tracer, _: Unit): Unit {
        tracer.visitKind(this.definition, EdgeKind.TemplateDeclarationEdge)
        for (argument in this.arguments) {
            tracer.visitKind(argument, EdgeKind.TemplateArgumentEdge)
        }
    }
}
