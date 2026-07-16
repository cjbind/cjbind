package cjbind.ir

import std.collection.{ArrayList, HashMap, collectArrayList}
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

public func selfTemplateParameterCount(id: ItemId, ctx: CjbindContext): Int64 {
    let item = match (ctx.resolveItemFallible(id)) {
        case Some(value) => value
        case None => return 0
    }
    let ty = match (item.kind.asType()) {
        case Some(value) => value
        case None => return 0
    }
    return match (ty.kind) {
        case TypeKind.TypeKindComp(comp) =>
            comp.templateParams.size + comp.nonTypeTemplateParams.size
        case TypeKind.TypeKindTemplateAlias(_, parameters) => parameters.size
        case TypeKind.ResolvedTypeRef(inner) => selfTemplateParameterCount(inner, ctx)
        case _ => 0
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

public class NonTypeTemplateArgument {
    public let position: UInt32
    public let signedValue: Int64
    public let unsignedValue: UInt64
    public let isUnsigned: Bool
    public let isBoolean: Bool
    /// Fully-qualified C++ enum type spelling used when a bridge source must
    /// reconstruct this integral template argument.
    public let enumTypeSpelling: ?String

    public init(
        position: UInt32,
        signedValue: Int64,
        unsignedValue: UInt64,
        isUnsigned: Bool,
        isBoolean!: Bool = false,
        enumTypeSpelling!: ?String = None
    ) {
        this.position = position
        this.signedValue = signedValue
        this.unsignedValue = unsignedValue
        this.isUnsigned = isUnsigned
        this.isBoolean = isBoolean
        this.enumTypeSpelling = enumTypeSpelling
    }

    public func displayValue(): String {
        if (this.isUnsigned) {
            return this.unsignedValue.toString()
        }
        return this.signedValue.toString()
    }

    public func disambiguatedName(): String {
        return this.displayValue().replace("-", "minus_")
    }

    public func sameIdentity(other: NonTypeTemplateArgument): Bool {
        return this.position == other.position &&
            this.signedValue == other.signedValue &&
            this.unsignedValue == other.unsignedValue &&
            this.isUnsigned == other.isUnsigned &&
            this.isBoolean == other.isBoolean &&
            this.enumTypeSpelling == other.enumTypeSpelling
    }
}

class NonTypeTemplateParameterMetadata {
    let isUnsigned: Bool
    let isBoolean: Bool
    let isEnum: Bool
    let enumTypeSpelling: ?String
    /// True only when the parameter declaration fixes a concrete integral,
    /// boolean, or enum type. `auto`, `decltype(auto)`, and dependent NTTP
    /// types need the argument's deduced type as part of their identity, which
    /// libclang's integral-value API does not expose losslessly here.
    let identityComplete: Bool

    init(
        isUnsigned: Bool,
        isBoolean: Bool,
        isEnum: Bool,
        enumTypeSpelling: ?String,
        identityComplete: Bool
    ) {
        this.isUnsigned = isUnsigned
        this.isBoolean = isBoolean
        this.isEnum = isEnum
        this.enumTypeSpelling = enumTypeSpelling
        this.identityComplete = identityComplete
    }
}

func hasConcreteIntegralTemplateParameterType(parameter: clang.Cursor): Bool {
    var parameterType = parameter.curType().canonicalType()
    if (parameterType.kind() == clang.CXTypeKind_CXType_Enum) {
        parameterType = match (parameterType.declaration().enumType()) {
            case Some(integerType) => integerType.canonicalType()
            case None => return false
        }
    }
    let kind = parameterType.kind()
    return kind == clang.CXTypeKind_CXType_Bool ||
        kind == clang.CXTypeKind_CXType_Char_U ||
        kind == clang.CXTypeKind_CXType_UChar ||
        kind == clang.CXTypeKind_CXType_Char16 ||
        kind == clang.CXTypeKind_CXType_Char32 ||
        kind == clang.CXTypeKind_CXType_UShort ||
        kind == clang.CXTypeKind_CXType_UInt ||
        kind == clang.CXTypeKind_CXType_ULong ||
        kind == clang.CXTypeKind_CXType_ULongLong ||
        kind == clang.CXTypeKind_CXType_Char_S ||
        kind == clang.CXTypeKind_CXType_SChar ||
        kind == clang.CXTypeKind_CXType_WChar ||
        kind == clang.CXTypeKind_CXType_Short ||
        kind == clang.CXTypeKind_CXType_Int ||
        kind == clang.CXTypeKind_CXType_Long ||
        kind == clang.CXTypeKind_CXType_LongLong
}

func isUnsignedIntegralTemplateParameter(parameter: clang.Cursor): Bool {
    var ty = parameter.curType().canonicalType()
    if (ty.kind() == clang.CXTypeKind_CXType_Enum) {
        if (let Some(integerType) <- ty.declaration().enumType()) {
            ty = integerType.canonicalType()
        }
    }
    let kind = ty.kind()
    return kind == clang.CXTypeKind_CXType_Bool ||
        kind == clang.CXTypeKind_CXType_Char_U ||
        kind == clang.CXTypeKind_CXType_UChar ||
        kind == clang.CXTypeKind_CXType_Char16 ||
        kind == clang.CXTypeKind_CXType_Char32 ||
        kind == clang.CXTypeKind_CXType_UShort ||
        kind == clang.CXTypeKind_CXType_UInt ||
        kind == clang.CXTypeKind_CXType_ULong ||
        kind == clang.CXTypeKind_CXType_ULongLong ||
        kind == clang.CXTypeKind_CXType_UInt128
}

func templateParameterIsPackOrUninspectable(parameter: clang.Cursor): Bool {
    let tokens = clang.RawTokens(parameter)
    try {
        if (tokens.tokenCount == 0u32) {
            return true
        }
        for (token in tokens) {
            if (token.spelling() == "...") {
                return true
            }
        }
        return false
    } finally {
        tokens.close()
    }
}

func templateDefinitionHasParameterPackOrUnknown(definition: clang.Cursor): Bool {
    let result = Box(false)
    definition.visit {
        parameter =>
        let kind = parameter.kind()
        if ((kind == clang.CXCursorKind_CXCursor_TemplateTypeParameter ||
            kind == clang.CXCursorKind_CXCursor_NonTypeTemplateParameter ||
            kind == clang.CXCursorKind_CXCursor_TemplateTemplateParameter) &&
            templateParameterIsPackOrUninspectable(parameter)) {
            result.value = true
        }
        return clang.CXChildVisitResult_CXChildVisit_Continue
    }
    return result.value
}

func templateDefinitionHasExactlyFixedTypeParameters(
    definition: clang.Cursor,
    expectedCount: Int64
): Bool {
    if (expectedCount == 0) {
        return false
    }
    let parameterCount = Box(0)
    let onlyTypeParameters = Box(true)
    definition.visit {
        parameter =>
        let kind = parameter.kind()
        if (kind == clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
            parameterCount.value += 1
            if (templateParameterIsPackOrUninspectable(parameter)) {
                onlyTypeParameters.value = false
            }
        } else if (kind == clang.CXCursorKind_CXCursor_NonTypeTemplateParameter ||
            kind == clang.CXCursorKind_CXCursor_TemplateTemplateParameter) {
            parameterCount.value += 1
            onlyTypeParameters.value = false
        }
        return clang.CXChildVisitResult_CXChildVisit_Continue
    }
    return onlyTypeParameters.value && parameterCount.value == expectedCount
}

func nonTypeTemplateParameterMetadata(
    specialization: clang.Cursor
): HashMap<UInt32, NonTypeTemplateParameterMetadata> {
    let result = HashMap<UInt32, NonTypeTemplateParameterMetadata>()
    let definition = specialization.specialized().getOrDefault({=> specialization})
    let position = Box(0u32)
    definition.visit {
        parameter =>
        let kind = parameter.kind()
        if (kind == clang.CXCursorKind_CXCursor_TemplateTypeParameter ||
            kind == clang.CXCursorKind_CXCursor_TemplateTemplateParameter) {
            position.value += 1
        } else if (kind == clang.CXCursorKind_CXCursor_NonTypeTemplateParameter) {
            let parameterType = parameter.curType().canonicalType()
            let isEnum = parameterType.kind() == clang.CXTypeKind_CXType_Enum
            let enumTypeSpelling: ?String = if (isEnum) {
                let spelling = parameterType.spelling()
                if (spelling.isEmpty()) { None } else { Some(spelling) }
            } else {
                None
            }
            result.add(position.value, NonTypeTemplateParameterMetadata(
                isUnsignedIntegralTemplateParameter(parameter),
                parameterType.kind() == clang.CXTypeKind_CXType_Bool,
                isEnum,
                enumTypeSpelling,
                hasConcreteIntegralTemplateParameterType(parameter)
            ))
            position.value += 1
        }
        return clang.CXChildVisitResult_CXChildVisit_Continue
    }
    return result
}

public func concreteTemplateArgumentsFromTy(
    ty: clang.Type,
    parentId: ?ItemId,
    ctx: CjbindContext
): ?(Array<TypeId>, Array<NonTypeTemplateArgument>) {
    let specialization = ty.declaration()
    let count = match (specialization.numTemplateArgs()) {
        case Some(value) where value > 0 => value
        case _ => return None
    }
    let parameterMetadata = nonTypeTemplateParameterMetadata(specialization)
    let definition = specialization.specialized().getOrDefault({=> specialization})
    if (templateDefinitionHasParameterPackOrUnknown(definition)) {
        return None
    }
    let typeArguments = ArrayList<TypeId>()
    let nonTypeArguments = ArrayList<NonTypeTemplateArgument>()
    for (index in 0u32..count) {
        let kind = match (specialization.templateArgumentKind(index)) {
            case Some(value) => value
            case None => return None
        }
        if (kind == clang.CXTemplateArgumentKind_CXTemplateArgumentKind_Type) {
            let argument = match (specialization.templateArgumentType(index)) {
                case Some(value) => value
                case None => return None
            }
            typeArguments.add(Item.fromTyOrRef(
                argument,
                argument.declaration(),
                parentId,
                ctx
            ))
        } else if (kind == clang.CXTemplateArgumentKind_CXTemplateArgumentKind_Integral) {
            let metadata = match (parameterMetadata.get(index)) {
                case Some(value) => value
                case None => return None
            }
            if (!metadata.identityComplete) {
                return None
            }
            if (metadata.isEnum && metadata.enumTypeSpelling.isNone()) {
                return None
            }
            let signedValue = match (specialization.templateArgumentValue(index)) {
                case Some(value) => value
                case None => return None
            }
            let unsignedValue = match (specialization.templateArgumentUnsignedValue(index)) {
                case Some(value) => value
                case None => return None
            }
            nonTypeArguments.add(NonTypeTemplateArgument(
                index,
                signedValue,
                unsignedValue,
                metadata.isUnsigned,
                isBoolean: metadata.isBoolean,
                enumTypeSpelling: metadata.enumTypeSpelling
            ))
        } else {
            return None
        }
    }
    return Some((typeArguments.toArray(), nonTypeArguments.toArray()))
}

/// Returns true when libclang reports a concrete argument kind that cjbind
/// cannot represent without losing its identity.  In particular, declaration,
/// pointer/nullptr, expression, template and pack arguments must never fall
/// through to the type-only cursor fallback: doing so can accidentally turn a
/// specialization into its primary template or merge two distinct instances.
public func hasUnsupportedConcreteTemplateArgument(ty: clang.Type): Bool {
    let specialization = ty.declaration()
    let count = match (specialization.numTemplateArgs()) {
        case Some(value) where value > 0 => value
        case _ =>
            // clang_Type_getTemplateArgumentAsType returns an invalid type
            // for non-type positions. An all-valid list is therefore
            // safe to send through the type-only fallback; any invalid entry
            // still denotes an identity we cannot reconstruct losslessly.
            return ty.templateArgs()
                .map({arguments => arguments.any {argument => !argument.isValid()}})
                .getOrDefault({=> false})
    }
    let parameterMetadata = nonTypeTemplateParameterMetadata(specialization)
    let definition = specialization.specialized().getOrDefault({=> specialization})
    if (templateDefinitionHasParameterPackOrUnknown(definition)) {
        return true
    }
    for (index in 0u32..count) {
        let kind = match (specialization.templateArgumentKind(index)) {
            case Some(value) => value
            case None => return true
        }
        if (kind == clang.CXTemplateArgumentKind_CXTemplateArgumentKind_Integral) {
            let metadata = match (parameterMetadata.get(index)) {
                case Some(value) => value
                case None => return true
            }
            if (!metadata.identityComplete ||
                (metadata.isEnum && metadata.enumTypeSpelling.isNone())) {
                return true
            }
        } else if (kind != clang.CXTemplateArgumentKind_CXTemplateArgumentKind_Type) {
            return true
        }
    }
    return false
}

public class TemplateInstantiation <: Trace<Tracer, Unit> {
    public let definition: TypeId
    public let arguments: Array<TypeId>
    public let nonTypeArguments: Array<NonTypeTemplateArgument>
    public let concrete: ?CompInfo
    /// False when at least one concrete C++ template argument could not be
    /// represented losslessly.  Such instances retain their own Clang layout
    /// but are deliberately never materialized or deduplicated.
    public let argumentsComplete: Bool

    public init(
        definition: TypeId,
        arguments: Array<TypeId>,
        nonTypeArguments!: Array<NonTypeTemplateArgument> = Array<NonTypeTemplateArgument>(),
        concrete!: ?CompInfo = None,
        argumentsComplete!: Bool = true
    ) {
        this.definition = definition
        this.arguments = arguments
        this.nonTypeArguments = nonTypeArguments
        this.concrete = concrete
        this.argumentsComplete = argumentsComplete
    }

    public func argumentCount(): Int64 {
        return this.arguments.size + this.nonTypeArguments.size
    }

    public func nonTypeArgumentAt(position: UInt32): ?NonTypeTemplateArgument {
        for (argument in this.nonTypeArguments) {
            if (argument.position == position) {
                return Some(argument)
            }
        }
        return None
    }

    public static func fromTy(
        ty: clang.Type,
        withId: ItemId,
        ctx: CjbindContext
    ): ?TemplateInstantiation {
        let arguments = ArrayList<TypeId>()
        var nonTypeArguments = Array<NonTypeTemplateArgument>()
        var fallbackTypePositions = 0
        var fallbackContainsOnlyTypes = false
        // A TemplateRef/instantiation is incomplete until the cursor API has
        // supplied every argument with a lossless kind and identity. Starting
        // at true would let metadata-free libclang AST shapes enter the
        // materialization cache under an invented empty argument list.
        var argumentsComplete = false
        if (let Some((directTypes, directValues)) <- concreteTemplateArgumentsFromTy(ty, None, ctx)) {
            arguments.add(all: directTypes)
            nonTypeArguments = directValues
            argumentsComplete = true
        } else if (let Some(directArguments) <- ty.templateArgs()) {
            // Invalid entries are non-type positions. Keep valid types for
            // dependency tracing, then validate the complete positional count
            // against the template declaration after resolving it below.
            fallbackTypePositions = directArguments.size
            fallbackContainsOnlyTypes = true
            for (argument in directArguments) {
                if (argument.isValid()) {
                    arguments.add(Item.fromTyOrRef(
                        argument,
                        argument.declaration(),
                        None,
                        ctx
                    ))
                } else {
                    fallbackContainsOnlyTypes = false
                }
            }
            if (let Some(canonicalArguments) <- ty.canonicalType().templateArgs()) {
                if (canonicalArguments.size > directArguments.size) {
                    fallbackTypePositions = canonicalArguments.size
                    for (index in directArguments.size..canonicalArguments.size) {
                        let argument = canonicalArguments[index]
                        if (argument.isValid()) {
                            arguments.add(Item.fromTyOrRef(
                                argument,
                                argument.declaration(),
                                None,
                                ctx
                            ))
                        } else {
                            fallbackContainsOnlyTypes = false
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
        if (!argumentsComplete && fallbackContainsOnlyTypes) {
            argumentsComplete = fallbackTypePositions == arguments.size &&
                templateDefinitionHasExactlyFixedTypeParameters(
                    definitionCursor,
                    fallbackTypePositions
                )
        }
        if (definitionCursor.kind() == clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl &&
            !templateDefinitionHasExactlyFixedTypeParameters(
                definitionCursor,
                arguments.size
            )) {
            // Alias-template IR currently maps type parameters only. Do not
            // pretend that an NTTP, template-template argument, or pack has a
            // lossless substitution identity.
            argumentsComplete = false
        }
        return Some(TemplateInstantiation(
            templateDefinition,
            arguments.toArray(),
            nonTypeArguments: nonTypeArguments,
            concrete: ctx.concreteTemplateComp(withId, ty),
            argumentsComplete: argumentsComplete
        ))
    }

    public func trace(_: CjbindContext, tracer: Tracer, _: Unit): Unit {
        if (!this.argumentsComplete) {
            return
        }
        tracer.visitKind(this.definition, EdgeKind.TemplateDeclarationEdge)
        for (argument in this.arguments) {
            tracer.visitKind(argument, EdgeKind.TemplateArgumentEdge)
        }
    }

    public func traceConcreteLayout(
        context: CjbindContext,
        tracer: Tracer,
        item: Item
    ): Unit {
        if (!this.argumentsComplete) {
            return
        }
        let info = match (this.concrete) {
            case Some(value) => value
            case None => return
        }
        for (inner in info.innerTypes) {
            tracer.visitKind(inner, EdgeKind.InnerTypeEdge)
        }
        if (item.isOpaque(context, ())) {
            return
        }
        for (base in info.baseMembers) {
            tracer.visitKind(base.ty, EdgeKind.BaseMemberEdge)
        }
        info.fields.trace(context, tracer, ())
    }
}

public func canonicalItemId(ctx: CjbindContext, start: ItemId): ItemId {
    let visited = ItemSet()
    var current = start
    while (visited.add(current)) {
        let item = match (ctx.resolveItemFallible(current)) {
            case Some(value) => value
            case None => return current
        }
        let ty = match (item.asType()) {
            case Some(value) => value
            case None => return current
        }
        match (ty.kind) {
            case TypeKind.TypeKindAlias(inner) => current = inner
            case TypeKind.ResolvedTypeRef(inner) => current = inner
            case _ => return current
        }
    }
    return current
}
