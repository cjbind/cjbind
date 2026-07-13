package cjbind.ir

import std.collection.ArrayList
import cjbind.clang

public class TemplateInstantiation <: Trace<Tracer, Unit> {
    public let definition: TypeId
    public let arguments: Array<TypeId>
    public let definitionCursor: clang.Cursor
    public let nonTypeIdentity: ?String

    public init(
        definition: TypeId,
        arguments: Array<TypeId>,
        definitionCursor: clang.Cursor,
        nonTypeIdentity: ?String
    ) {
        this.definition = definition
        this.arguments = arguments
        this.definitionCursor = definitionCursor
        this.nonTypeIdentity = nonTypeIdentity
    }

    public static func fromTy(ty: clang.Type, ctx: CjbindContext): ?TemplateInstantiation {
        let arguments = ArrayList<TypeId>()
        let directArguments = ty.templateArgs().getOrDefault({=> Array<clang.Type>()})
        let canonicalArguments = ty.canonicalType().templateArgs().getOrDefault({=> Array<clang.Type>()})
        let argumentCount = max(directArguments.size, canonicalArguments.size)
        var hasNonTypeArgument = false
        for (i in 0..argumentCount) {
            var argument: ?clang.Type = None
            if (i < directArguments.size && directArguments[i].isValid()) {
                argument = Some(directArguments[i])
            } else if (i < canonicalArguments.size && canonicalArguments[i].isValid()) {
                argument = Some(canonicalArguments[i])
            }
            match (argument) {
                case Some(value) =>
                    arguments.add(Item.fromTyOrRef(value, value.declaration(), None, ctx))
                case None => hasNonTypeArgument = true
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

        let templateCursor = match (definition) {
            case Some(value) => value
            case None => return None
        }
        let templateDefinition = ctx.getResolvedType(
            clang.CanonicalTypeDeclaration(templateCursor.curType(), templateCursor.canonical())
        ).getOrDefault {
            => Item.fromTyOrRef(
                templateCursor.curType(),
                templateCursor,
                None,
                ctx
            )
        }
        let nonTypeIdentity: ?String = if (hasNonTypeArgument) {
            Some(ty.canonicalType().spelling())
        } else {
            None
        }
        return Some(TemplateInstantiation(
            templateDefinition,
            arguments.toArray(),
            templateCursor.canonical(),
            nonTypeIdentity
        ))
    }

    public func trace(_: CjbindContext, tracer: Tracer, _: Unit): Unit {
        tracer.visitKind(this.definition, EdgeKind.TemplateParameterDefinitionEdge)
        for (argument in this.arguments) {
            tracer.visitKind(argument, EdgeKind.TemplateArgumentEdge)
        }
    }
}
