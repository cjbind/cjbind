package cjbind.codegen

import cjbind_token.*
import cjbind_token.macros.*
import std.collection.ArrayList
import cjbind.ir.*
import cjbind.options.{DefaultAliasStyle, DefaultEnumStyle}

/// Cangjie has no Rust-style `Deref` or user-defined implicit conversions.
/// Keep the `new_type_deref` spelling for bindgen compatibility, but expose
/// the conversion explicitly so that the generated strong type remains safe.
func newTypeAliasDeclaration(
    ident: String,
    innerType: TokenStream,
    style: DefaultAliasStyle
): TokenStream {
    let accessors = if (style == DefaultAliasStyle.NewTypeDeref) {
        @tmpl(
            public mut prop value: ${innerType} {
                get() {
                    return this.rawValue
                }
                set(value) {
                    this.rawValue = value
                }
            }

            public static func wrap(rawValue: ${innerType}): ${ident} {
                return ${ident}(rawValue: rawValue)
            }

            public func unwrap(): ${innerType} {
                return this.rawValue
            }
        )
    } else {
        TokenStream()
    }

    return @tmpl(
        @C
        public struct ${ident} {
            public var rawValue: ${innerType}

            public init(rawValue!: ${innerType}) {
                this.rawValue = rawValue
            }

            ${accessors}
        }
    )
}

func aliasInnerType(item: Item): ?TypeId {
    return match (item.kind.expectType().kind) {
        case TypeKind.TypeKindAlias(inner) => Some(inner)
        case TypeKind.TypeKindTemplateAlias(inner, _) => Some(inner)
        case _ => None
    }
}

func supportedAliasStyle(
    ctx: CjbindContext,
    item: Item,
    target: Item,
    hasGenericParameters: Bool
): DefaultAliasStyle {
    let style = ctx.options.aliasStyle(ctx.itemPolicyName(item))
    if (style == DefaultAliasStyle.TypeAlias) {
        return style
    }
    if (hasGenericParameters || item.isOpaque(ctx, ()) || target.isOpaque(ctx, ())) {
        return DefaultAliasStyle.TypeAlias
    }
    let targetType = target.kind.expectType().canonicalType(ctx)
    match (targetType.kind) {
        case TypeKind.TypeKindVoid | TypeKind.TypeKindArray(_, _) |
            TypeKind.TypeKindFunction(_) =>
            return DefaultAliasStyle.TypeAlias
        case TypeKind.TypeKindComp(comp) =>
            if (comp.isCxxRecord) {
                return DefaultAliasStyle.TypeAlias
            }
        case _ => ()
    }
    let targetLayout = match (targetType.getLayout(ctx)) {
        case Some(value) => value
        case None => return DefaultAliasStyle.TypeAlias
    }
    if (targetLayout.align > ctx.pointerWidth() ||
        Layout.knownCjTypeForSize(targetLayout.align).isNone()) {
        return DefaultAliasStyle.TypeAlias
    }
    return style
}

func effectiveAliasStyle(
    ctx: CjbindContext,
    item: Item,
    target: Item,
    hasGenericParameters: Bool
): DefaultAliasStyle {
    let requested = ctx.options.aliasStyle(ctx.itemPolicyName(item))
    let supported = supportedAliasStyle(ctx, item, target, hasGenericParameters)
    if (requested == supported) {
        return supported
    }

    let name = item.canonicalName(ctx)
    if (hasGenericParameters) {
        eprintln(
            "Warning: generating alias '${name}' as a regular type alias because @C structs cannot have generic parameters"
        )
    } else if (item.isOpaque(ctx, ()) || target.isOpaque(ctx, ())) {
        eprintln(
            "Warning: generating alias '${name}' as a regular type alias because an opaque alias cannot be safely unwrapped at an FFI value boundary"
        )
    } else {
        let targetType = target.kind.expectType().canonicalType(ctx)
        match (targetType.kind) {
            case TypeKind.TypeKindVoid =>
                eprintln(
                    "Warning: generating alias '${name}' as a regular type alias because Unit cannot be an @C struct field"
                )
            case TypeKind.TypeKindArray(_, _) =>
                eprintln(
                    "Warning: generating alias '${name}' as a regular type alias because C array parameters decay to pointers"
                )
            case TypeKind.TypeKindFunction(_) =>
                eprintln(
                    "Warning: generating alias '${name}' as a regular type alias because a bare function type is not a C object type"
                )
            case TypeKind.TypeKindComp(comp) =>
                if (comp.isCxxRecord) {
                    eprintln(
                        "Warning: generating alias '${name}' as a regular type alias because a Cangjie newtype cannot preserve C++ record copy and lifetime semantics"
                    )
                }
            case _ =>
                match (targetType.getLayout(ctx)) {
                    case None =>
                        eprintln(
                            "Warning: generating alias '${name}' as a regular type alias because its target has no complete object layout"
                        )
                    case Some(layout) =>
                        if (layout.align > ctx.pointerWidth() ||
                            Layout.knownCjTypeForSize(layout.align).isNone()) {
                            eprintln(
                                "Warning: generating alias '${name}' as a regular type alias because its alignment cannot be represented by a Cangjie @C newtype; use values obtained from C only through pointers"
                            )
                        }
                }
        }
    }
    return supported
}

func aliasDefinition(
    ctx: CjbindContext,
    typeId: TypeId
): ?(Item, TypeId) {
    let resolved = typeId.intoResolver().throughTypeRefs().resolve(ctx)
    if (let Some(inner) <- aliasInnerType(resolved)) {
        return Some((resolved, inner))
    }
    if (let Some((definitionId, _)) <- ctx.codegenAliasUse(resolved.id)) {
        let definition = ctx.resolveItem(definitionId)
        if (let Some(inner) <- aliasInnerType(definition)) {
            return Some((definition, inner))
        }
    }
    return None
}

func aliasStyleForUse(
    ctx: CjbindContext,
    item: Item,
    inner: TypeId
): DefaultAliasStyle {
    let source = item.kind.expectType()
    if (let Some(sourceName) <- source.name) {
        if (Utils.typeFromNamed(ctx, sourceName).isSome()) {
            return DefaultAliasStyle.TypeAlias
        }
    }
    let hasGenericParameters = if (item.isOpaque(ctx, ())) {
        false
    } else {
        !ctx.usedTemplateParams(item.id).isEmpty()
    }
    let target = inner
        .intoResolver()
        .throughTypeRefs()
        .throughTypeAliases()
        .resolve(ctx)
    return supportedAliasStyle(ctx, item, target, hasGenericParameters)
}

func aliasChainNeedsValueConversion(
    ctx: CjbindContext,
    typeId: TypeId,
    visiting: ItemSet
): Bool {
    let definition = match (aliasDefinition(ctx, typeId)) {
        case Some(value) => value
        case None => return false
    }
    let item = definition[0]
    let inner = definition[1]
    if (visiting.contains(item.id)) {
        return false
    }
    visiting.add(item.id)
    if (aliasStyleForUse(ctx, item, inner) != DefaultAliasStyle.TypeAlias) {
        return true
    }
    if (!ctx.usedTemplateParams(item.id).isEmpty()) {
        return false
    }
    return aliasChainNeedsValueConversion(ctx, inner, visiting)
}

func aliasChainNeedsValueConversion(ctx: CjbindContext, typeId: TypeId): Bool {
    return aliasChainNeedsValueConversion(ctx, typeId, ItemSet())
}

func aliasAbiTarget(
    ctx: CjbindContext,
    typeId: TypeId,
    visiting: ItemSet
): TypeId {
    let resolved = typeId.intoResolver().throughTypeRefs().resolve(ctx)
    let definition = match (aliasDefinition(ctx, resolved.id)) {
        case Some(value) => value
        case None => return resolved.id
    }
    let item = definition[0]
    if (visiting.contains(item.id)) {
        return resolved.id
    }
    visiting.add(item.id)
    return aliasAbiTarget(ctx, definition[1], visiting)
}

func aliasAbiTarget(ctx: CjbindContext, typeId: TypeId): TypeId {
    return aliasAbiTarget(ctx, typeId, ItemSet())
}

func unwrapAliasValue(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream,
    visiting: ItemSet
): TokenStream {
    let definition = match (aliasDefinition(ctx, typeId)) {
        case Some(value) => value
        case None => return expression
    }
    let item = definition[0]
    let inner = definition[1]
    if (visiting.contains(item.id)) {
        return expression
    }
    visiting.add(item.id)
    let nextExpression = if (aliasStyleForUse(ctx, item, inner) == DefaultAliasStyle.TypeAlias) {
        expression
    } else {
        tokenStreamFromTemplate("${expression}.rawValue")
    }
    return unwrapAliasValue(ctx, inner, nextExpression, visiting)
}

func unwrapAliasValue(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream
): TokenStream {
    return unwrapAliasValue(ctx, typeId, expression, ItemSet())
}

func wrapAliasValue(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream,
    visiting: ItemSet
): TokenStream {
    let definition = match (aliasDefinition(ctx, typeId)) {
        case Some(value) => value
        case None => return expression
    }
    let item = definition[0]
    let inner = definition[1]
    if (visiting.contains(item.id)) {
        return expression
    }
    visiting.add(item.id)
    let innerExpression = wrapAliasValue(ctx, inner, expression, visiting)
    if (aliasStyleForUse(ctx, item, inner) == DefaultAliasStyle.TypeAlias) {
        return innerExpression
    }
    let ident = ctx.cjIdent(item.canonicalName(ctx))
    return tokenStreamFromTemplate("${ident}(rawValue: ${innerExpression})")
}

func wrapAliasValue(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream
): TokenStream {
    return wrapAliasValue(ctx, typeId, expression, ItemSet())
}

func valueBoundaryNeedsConversion(
    ctx: CjbindContext,
    typeId: TypeId,
    visiting: ItemSet
): Bool {
    let definition = aliasDefinition(ctx, typeId)
    if (let Some((item, inner)) <- definition) {
        if (!visiting.add(item.id)) {
            return false
        }
        if (aliasStyleForUse(ctx, item, inner) != DefaultAliasStyle.TypeAlias) {
            return true
        }
        return valueBoundaryNeedsConversion(ctx, inner, visiting)
    }

    let resolved = typeId.intoResolver().throughTypeRefs().resolve(ctx)
    return match (resolved.kind.expectType().kind) {
        case TypeKind.TypeKindEnum(_) => ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType
        case _ => false
    }
}

func valueBoundaryNeedsConversion(ctx: CjbindContext, typeId: TypeId): Bool {
    return valueBoundaryNeedsConversion(ctx, typeId, ItemSet())
}

func valueBoundaryAbiTarget(
    ctx: CjbindContext,
    typeId: TypeId,
    visiting: ItemSet
): TypeId {
    if (let Some((item, inner)) <- aliasDefinition(ctx, typeId)) {
        if (!visiting.add(item.id)) {
            return item.id
        }
        return valueBoundaryAbiTarget(ctx, inner, visiting)
    }

    let resolved = typeId.intoResolver().throughTypeRefs().resolve(ctx)
    if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
        if (let TypeKind.TypeKindEnum(value) <- resolved.kind.expectType().kind) {
            return match (value.repr) {
                case Some(repr) => valueBoundaryAbiTarget(ctx, repr, visiting)
                case None => resolved.id
            }
        }
    }
    return resolved.id
}

func valueBoundaryAbiTarget(ctx: CjbindContext, typeId: TypeId): TypeId {
    return valueBoundaryAbiTarget(ctx, typeId, ItemSet())
}

func unwrapValueBoundary(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream,
    visiting: ItemSet
): TokenStream {
    if (let Some((item, inner)) <- aliasDefinition(ctx, typeId)) {
        if (!visiting.add(item.id)) {
            return expression
        }
        let next = if (aliasStyleForUse(ctx, item, inner) == DefaultAliasStyle.TypeAlias) {
            expression
        } else {
            tokenStreamFromTemplate("${expression}.rawValue")
        }
        return unwrapValueBoundary(ctx, inner, next, visiting)
    }

    let resolved = typeId.intoResolver().throughTypeRefs().resolve(ctx)
    if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
        if (let TypeKind.TypeKindEnum(_) <- resolved.kind.expectType().kind) {
            return tokenStreamFromTemplate("${expression}.rawValue")
        }
    }
    return expression
}

func unwrapValueBoundary(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream
): TokenStream {
    return unwrapValueBoundary(ctx, typeId, expression, ItemSet())
}

func wrapValueBoundary(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream,
    visiting: ItemSet
): TokenStream {
    if (let Some((item, inner)) <- aliasDefinition(ctx, typeId)) {
        if (!visiting.add(item.id)) {
            return expression
        }
        let innerExpression = wrapValueBoundary(ctx, inner, expression, visiting)
        if (aliasStyleForUse(ctx, item, inner) == DefaultAliasStyle.TypeAlias) {
            return innerExpression
        }
        let ident = ctx.cjIdent(item.canonicalName(ctx))
        return tokenStreamFromTemplate("${ident}(rawValue: ${innerExpression})")
    }

    let resolved = typeId.intoResolver().throughTypeRefs().resolve(ctx)
    if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
        if (let TypeKind.TypeKindEnum(_) <- resolved.kind.expectType().kind) {
            let ident = ctx.cjIdent(resolved.canonicalName(ctx))
            return tokenStreamFromTemplate("${ident}(rawValue: ${expression})")
        }
    }
    return expression
}

func wrapValueBoundary(
    ctx: CjbindContext,
    typeId: TypeId,
    expression: TokenStream
): TokenStream {
    return wrapValueBoundary(ctx, typeId, expression, ItemSet())
}

func newTypeFunctionNeedsWrapper(ctx: CjbindContext, signature: FunctionSig): Bool {
    if (valueBoundaryNeedsConversion(ctx, signature.returnType)) {
        return true
    }
    for ((_, argumentType) in signature.argumentTypes) {
        if (valueBoundaryNeedsConversion(ctx, argumentType)) {
            return true
        }
    }
    return false
}

func functionArgumentName(
    ctx: CjbindContext,
    name: ?String,
    unnamedArguments: Box<Int64>
): String {
    let rawName = match (name) {
        case Some(value) => value
        case None =>
            unnamedArguments.value += 1
            "arg${unnamedArguments.value}"
    }
    return ctx.cjIdent(ctx.cjMangle(rawName))
}

func newTypeAbiArguments(
    ctx: CjbindContext,
    signature: FunctionSig
): ArrayList<TokenStream> {
    let arguments = ArrayList<TokenStream>()
    let unnamedArguments = Box<Int64>(0)
    for ((name, typeId) in signature.argumentTypes) {
        let ident = functionArgumentName(ctx, name, unnamedArguments)
        let abiType = newTypeAbiArgumentType(ctx, typeId)
        arguments.add(tokenStreamFromTemplate("${ident}: ${abiType}"))
    }
    return arguments
}

func newTypeAbiArgumentType(
    ctx: CjbindContext,
    typeId: TypeId
): TokenStream {
    if (valueBoundaryNeedsConversion(ctx, typeId)) {
        return Utils.fnsigArgumentType(ctx, valueBoundaryAbiTarget(ctx, typeId))
    }
    return Utils.fnsigArgumentType(ctx, typeId)
}

func newTypeAbiReturnType(
    ctx: CjbindContext,
    signature: FunctionSig
): TokenStream {
    if (!valueBoundaryNeedsConversion(ctx, signature.returnType)) {
        return Utils.fnsigReturnTy(ctx, signature)
    }
    let target = valueBoundaryAbiTarget(ctx, signature.returnType)
    let targetType = ctx.resolveType(target).canonicalType(ctx)
    return match (targetType.kind) {
        case TypeKind.TypeKindVoid => tokenStreamFromTemplate("Unit")
        case _ => target.toCjTyOrOpaque(ctx, ())
    }
}

func newTypeAbiCallArguments(
    ctx: CjbindContext,
    signature: FunctionSig
): ArrayList<TokenStream> {
    let arguments = ArrayList<TokenStream>()
    let unnamedArguments = Box<Int64>(0)
    for ((name, typeId) in signature.argumentTypes) {
        let ident = functionArgumentName(ctx, name, unnamedArguments)
        let expression = tokenStreamFromTemplate(ident)
        arguments.add(if (valueBoundaryNeedsConversion(ctx, typeId)) {
            unwrapValueBoundary(ctx, typeId, expression)
        } else {
            expression
        })
    }
    return arguments
}
