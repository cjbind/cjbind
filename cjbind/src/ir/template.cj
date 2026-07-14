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

public enum TemplateInstantiationKind {
    Primary
    | ExplicitSpecialization
    | PartialSpecialization

    public func isPrimary(): Bool {
        return match (this) {
            case Primary => true
            case _ => false
        }
    }

    public func isExplicitSpecialization(): Bool {
        return match (this) {
            case ExplicitSpecialization => true
            case _ => false
        }
    }

    public func isPartialSpecialization(): Bool {
        return match (this) {
            case PartialSpecialization => true
            case _ => false
        }
    }
}

public class TemplateInstantiation <: Trace<Tracer, Unit> {
    public let definition: TypeId
    public let arguments: Array<TypeId>
    public let definitionCursor: clang.Cursor
    public let nonTypeIdentity: ?String
    public let kind: TemplateInstantiationKind
    public let spelling: ?String
    public let argumentSpellings: Array<String>
    public let allArgumentSpellings: Array<String>
    public let nonTypeArgumentSpellings: Array<String>
    public let typeArgumentPositions: Array<Int64>
    public let isDependent: Bool

    public init(
        definition: TypeId,
        arguments: Array<TypeId>,
        definitionCursor: clang.Cursor,
        nonTypeIdentity: ?String,
        kind!: TemplateInstantiationKind = TemplateInstantiationKind.Primary,
        spelling!: ?String = None,
        argumentSpellings!: Array<String> = Array<String>(),
        allArgumentSpellings!: Array<String> = Array<String>(),
        nonTypeArgumentSpellings!: Array<String> = Array<String>(),
        typeArgumentPositions!: Array<Int64> = Array<Int64>(),
        isDependent!: Bool = false
    ) {
        this.definition = definition
        this.arguments = arguments
        this.definitionCursor = definitionCursor
        this.nonTypeIdentity = nonTypeIdentity
        this.kind = kind
        this.spelling = spelling
        this.argumentSpellings = argumentSpellings
        this.allArgumentSpellings = allArgumentSpellings
        this.nonTypeArgumentSpellings = nonTypeArgumentSpellings
        this.typeArgumentPositions = typeArgumentPositions
        this.isDependent = isDependent
    }

    public static func fromTy(ty: clang.Type, ctx: CjbindContext): ?TemplateInstantiation {
        let arguments = ArrayList<TypeId>()
        let argumentSpellings = ArrayList<String>()
        let allArgumentSpellings = ArrayList<String>()
        let nonTypeArgumentSpellings = ArrayList<String>()
        let typeArgumentPositions = ArrayList<Int64>()
        let directArguments = ty.templateArgs().getOrDefault({=> Array<clang.Type>()})
        let canonicalArguments = ty.canonicalType().templateArgs().getOrDefault({=> Array<clang.Type>()})
        let argumentCount = max(directArguments.size, canonicalArguments.size)
        let declaration = ty.declaration()
        let parsedArgumentSpellings = splitTemplateArgumentSpellings(ty.spelling())
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
                    argumentSpellings.add(value.spelling())
                    allArgumentSpellings.add(value.spelling())
                    typeArgumentPositions.add(i)
                case None =>
                    hasNonTypeArgument = true
                    let valueSpelling = if (i < parsedArgumentSpellings.size &&
                        !parsedArgumentSpellings[i].isEmpty()) {
                        parsedArgumentSpellings[i]
                    } else {
                        declaration.templateArgumentValue(UInt32(i))
                            .map({value => value.toString()})
                            .getOrDefault({=> ""})
                    }
                    allArgumentSpellings.add(valueSpelling)
                    nonTypeArgumentSpellings.add(valueSpelling)
            }
        }

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
        var semanticParent = ctx.knownSemanticParent(templateCursor)
        if (semanticParent.isNone()) {
            semanticParent = ctx.knownSemanticParent(templateCursor.canonical())
        }
        if (let Some(templateDefinitionCursor) <- templateCursor.definition()) {
            if (let Some(parent) <- ctx.knownSemanticParent(templateDefinitionCursor)) {
                semanticParent = Some(parent)
            } else if (let Some(parent) <- ctx.knownSemanticParent(templateDefinitionCursor.canonical())) {
                semanticParent = Some(parent)
            }
        }
        if (semanticParent.isNone()) {
            if (let Some(parentCursor) <- templateCursor.fallibleSemanticParent()) {
                semanticParent = ctx.getResolvedType(clang.CanonicalTypeDeclaration(
                    parentCursor.curType(),
                    parentCursor.canonical()
                ))
            }
        }
        let resolvedSemanticParent = semanticParent
        var resolvedTemplateDefinition = ctx.getResolvedType(
            clang.CanonicalTypeDeclaration(templateCursor.curType(), templateCursor.canonical())
        )
        if (resolvedTemplateDefinition.isNone()) {
            for ((candidateCursor, candidateId) in ctx.typeDeclarations) {
                let isDefinition = match (ctx.resolveItemFallible(candidateId).flatMap({ item => item.kind.asType() })) {
                    case Some(candidateType) => match (candidateType.kind) {
                        case TypeKind.TypeKindComp(_) | TypeKind.TypeKindTemplateAlias(_, _) => true
                        case _ => false
                    }
                    case None => false
                }
                if (isDefinition && sameSourceLocation(candidateCursor, templateCursor)) {
                    resolvedTemplateDefinition = Some(candidateId)
                    break
                }
            }
        }
        let templateDefinition = match (resolvedTemplateDefinition) {
            case Some(value) => value
            case None => Item.fromTyOrRef(
                templateCursor.curType(),
                templateCursor,
                resolvedSemanticParent,
                ctx
            )
        }
        let nonTypeIdentity: ?String = if (hasNonTypeArgument) {
            Some(ty.canonicalType().spelling())
        } else {
            None
        }
        let instantiationKind = if (declaration.kind() ==
            clang.CXCursorKind_CXCursor_ClassTemplatePartialSpecialization ||
            templateCursor.kind() ==
                clang.CXCursorKind_CXCursor_ClassTemplatePartialSpecialization) {
            TemplateInstantiationKind.PartialSpecialization
        } else if (declaration.specialized().isSome() &&
            !sameSourceLocation(declaration, templateCursor)) {
            TemplateInstantiationKind.ExplicitSpecialization
        } else {
            TemplateInstantiationKind.Primary
        }
        return Some(TemplateInstantiation(
            templateDefinition,
            arguments.toArray(),
            templateCursor.canonical(),
            nonTypeIdentity,
            kind: instantiationKind,
            spelling: Some(ty.spelling()),
            argumentSpellings: argumentSpellings.toArray(),
            allArgumentSpellings: allArgumentSpellings.toArray(),
            nonTypeArgumentSpellings: nonTypeArgumentSpellings.toArray(),
            typeArgumentPositions: typeArgumentPositions.toArray(),
            isDependent: match (ty.fallibleLayout(ctx)) {
                case Err(LayoutError.LayoutErrorDependent) => true
                case _ => false
            }
        ))
    }

    public func trace(_: CjbindContext, tracer: Tracer, _: Unit): Unit {
        tracer.visitKind(this.definition, EdgeKind.TemplateDeclarationEdge)
        for (argument in this.arguments) {
            tracer.visitKind(argument, EdgeKind.TemplateArgumentEdge)
        }
    }
}

func splitTemplateArgumentSpellings(spelling: String): Array<String> {
    let result = ArrayList<String>()
    let open = match (spelling.indexOf("<")) {
        case Some(value) => value
        case None => return result.toArray()
    }
    var angleDepth = 1
    var parenDepth = 0
    var bracketDepth = 0
    var braceDepth = 0
    var quoteByte = 0u8
    var escaped = false
    var argumentStart = open + 1
    var index = argumentStart
    while (index < spelling.size) {
        let value = spelling[index]
        if (quoteByte != 0u8) {
            if (escaped) {
                escaped = false
            } else if (value == 92u8) {
                escaped = true
            } else if (value == quoteByte) {
                quoteByte = 0u8
            }
            index += 1
            continue
        }
        if (value == 39u8 || value == 34u8) {
            quoteByte = value
        } else if (value == 60u8) {
            angleDepth += 1
        } else if (value == 62u8) {
            angleDepth -= 1
            if (angleDepth == 0) {
                let argument = spelling[argumentStart..index].trimAscii()
                if (!argument.isEmpty()) {
                    result.add(argument)
                }
                break
            }
        } else if (value == 40u8) {
            parenDepth += 1
        } else if (value == 41u8) {
            parenDepth -= 1
        } else if (value == 91u8) {
            bracketDepth += 1
        } else if (value == 93u8) {
            bracketDepth -= 1
        } else if (value == 123u8) {
            braceDepth += 1
        } else if (value == 125u8) {
            braceDepth -= 1
        } else if (value == 44u8 && angleDepth == 1 && parenDepth == 0 &&
            bracketDepth == 0 && braceDepth == 0) {
            result.add(spelling[argumentStart..index].trimAscii())
            argumentStart = index + 1
        }
        index += 1
    }
    return result.toArray()
}

func splitAllTemplateArgumentSpellings(spelling: String): Array<String> {
    let result = ArrayList<String>()
    var angleDepth = 0
    var quoteByte = 0u8
    var escaped = false
    var groupStart: ?Int64 = None
    var index = 0
    while (index < spelling.size) {
        let value = spelling[index]
        if (quoteByte != 0u8) {
            if (escaped) {
                escaped = false
            } else if (value == 92u8) {
                escaped = true
            } else if (value == quoteByte) {
                quoteByte = 0u8
            }
            index += 1
            continue
        }
        if (value == 39u8 || value == 34u8) {
            quoteByte = value
        } else if (value == 60u8) {
            if (angleDepth == 0) {
                groupStart = Some(index)
            }
            angleDepth += 1
        } else if (value == 62u8 && angleDepth > 0) {
            angleDepth -= 1
            if (angleDepth == 0) {
                if (let Some(start) <- groupStart) {
                    result.add(all: splitTemplateArgumentSpellings(spelling[start..(index + 1)]))
                }
                groupStart = None
            }
        }
        index += 1
    }
    return result.toArray()
}

func sameSourceLocation(left: clang.Cursor, right: clang.Cursor): Bool {
    let (leftFile, _, _, leftOffset) = left.location().location()
    let (rightFile, _, _, rightOffset) = right.location().location()
    return leftFile.name() == rightFile.name() && leftOffset == rightOffset
}
