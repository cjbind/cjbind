package cjbind.codegen

import cjbind_token.*
import cjbind_token.macros.*
import std.collection.{ArrayList, HashSet}
import cjbind.ir.*
import cjbind.options.DefaultEnumStyle

class DerivedValue {
    let label: String
    let left: String
    let right: String
    let ty: ?TypeId

    init(label: String, left: String, right: String, ty: ?TypeId) {
        this.label = label
        this.left = left
        this.right = right
        this.ty = ty
    }
}

enum GeneratedDerivedCapability {
    Debug
    | Hash
    | Ordering
}

func deriveWarning(ctx: CjbindContext, item: Item, capability: String, reason: String): Unit {
    eprintln(
        "Warning: not generating ${capability} for '${item.canonicalName(ctx)}': ${reason}"
    )
}

func derivedMemberNameConflicts(
    ctx: CjbindContext,
    comp: CompInfo,
    isOpaque: Bool,
    generatedName: String
): Bool {
    if (isOpaque) {
        return false
    }
    for (base in comp.baseMembers) {
        if (base.requiresStorage(ctx) && ctx.cjIdent(base.fieldName) == generatedName) {
            return true
        }
    }
    for (field in comp.getFields()) {
        match (field) {
            case Field.DataMember(data) =>
                if (let Some(name) <- data.name) {
                    if (ctx.cjIdent(ctx.cjMangle(name)) == generatedName) {
                        return true
                    }
                }
            case Field.Bitfields(unit) =>
                for (bitfield in unit.bitfields) {
                    if (let Some(name) <- bitfield.data.name) {
                        if (ctx.cjIdent(ctx.cjMangle(name)) == generatedName) {
                            return true
                        }
                    }
                }
        }
    }
    return false
}

func generatedCapabilityMemberName(capability: GeneratedDerivedCapability): String {
    return match (capability) {
        case GeneratedDerivedCapability.Debug => "toString"
        case GeneratedDerivedCapability.Hash => "hashCode"
        case GeneratedDerivedCapability.Ordering => "__cjbindPartialCompare"
    }
}

func compHasGeneratedCapabilityConflict(
    ctx: CjbindContext,
    item: Item,
    comp: CompInfo,
    capability: GeneratedDerivedCapability,
    visiting: HashSet<ItemId>
): Bool {
    if (visiting.contains(item.id)) {
        return false
    }
    visiting.add(item.id)

    let isOpaque = item.isOpaque(ctx, ())
    if (derivedMemberNameConflicts(
        ctx,
        comp,
        isOpaque,
        generatedCapabilityMemberName(capability)
    )) {
        return true
    }
    if (isOpaque || comp.isUnion()) {
        return false
    }

    for (base in comp.baseMembers) {
        if (base.requiresStorage(ctx) &&
            typeHasGeneratedCapabilityConflict(ctx, base.ty, capability, visiting)) {
            return true
        }
    }
    for (field in comp.getFields()) {
        match (field) {
            case Field.DataMember(data) =>
                if (typeHasGeneratedCapabilityConflict(ctx, data.ty, capability, visiting)) {
                    return true
                }
            case Field.Bitfields(unit) =>
                for (bitfield in unit.bitfields) {
                    if (typeHasGeneratedCapabilityConflict(
                        ctx,
                        bitfield.data.ty,
                        capability,
                        visiting
                    )) {
                        return true
                    }
                }
        }
    }
    return false
}

func typeHasGeneratedCapabilityConflict(
    ctx: CjbindContext,
    tyId: TypeId,
    capability: GeneratedDerivedCapability,
    visiting: HashSet<ItemId>
): Bool {
    let item = tyId
        .intoResolver()
        .throughTypeRefs()
        .throughTypeAliases()
        .resolve(ctx)
    if (visiting.contains(item.id)) {
        return false
    }
    if (!ctx.allowlistedItems.getOrThrow().contains(item.id)) {
        return false
    }
    let ty = item.kind.expectType()
    return match (ty.kind) {
        case TypeKind.TypeKindArray(inner, _) =>
            typeHasGeneratedCapabilityConflict(ctx, inner, capability, visiting)
        case TypeKind.TypeKindVector(inner, _) =>
            typeHasGeneratedCapabilityConflict(ctx, inner, capability, visiting)
        case TypeKind.TypeKindComp(comp) =>
            compHasGeneratedCapabilityConflict(ctx, item, comp, capability, visiting)
        case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
            let definition = ctx.resolveItem(instantiation.definition)
            match (definition.kind.expectType().kind) {
                case TypeKind.TypeKindComp(comp) =>
                    compHasGeneratedCapabilityConflict(ctx, item, comp, capability, visiting)
                case _ => false
            }
        case _ => false
    }
}

func derivedValues(ctx: CjbindContext, item: Item, comp: CompInfo): Array<DerivedValue> {
    let values = ArrayList<DerivedValue>()
    if (ctx.hasVtablePointer(item.id)) {
        values.add(DerivedValue("vtable_", "this.vtable_", "right.vtable_", None))
    }
    for (base in comp.baseMembers) {
        if (!base.requiresStorage(ctx)) {
            continue
        }
        let ident = ctx.cjIdent(base.fieldName)
        values.add(DerivedValue(base.fieldName, "this.${ident}", "right.${ident}", Some(base.ty)))
    }
    for (field in comp.getFields()) {
        match (field) {
            case Field.DataMember(data) =>
                let name = match (data.name) {
                    case Some(value) => value
                    case None => continue
                }
                let ident = ctx.cjIdent(ctx.cjMangle(name))
                values.add(DerivedValue(name, "this.${ident}", "right.${ident}", Some(data.ty)))
            case Field.Bitfields(unit) =>
                for (bitfield in unit.bitfields) {
                    let name = match (bitfield.data.name) {
                        case Some(value) => value
                        case None => continue
                    }
                    let ident = ctx.cjIdent(ctx.cjMangle(name))
                    values.add(DerivedValue(
                        name,
                        "this.${ident}()",
                        "right.${ident}()",
                        Some(bitfield.data.ty)
                    ))
                }
        }
    }
    return values.toArray()
}

func isOpaqueFloat(ty: Type, ctx: CjbindContext): Bool {
    return match (ty.kind) {
        case TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindFloat128) => true
        case TypeKind.TypeKindFloat(TypeKindFloatKind.FloatKindLongDouble) =>
            ty.getLayout(ctx).map({layout => layout.size > 8}).getOrDefault({=> false})
        case _ => false
    }
}

func appendDebugValue(
    ctx: CjbindContext,
    tyId: TypeId,
    expression: String,
    statements: ArrayList<TokenStream>,
    depth: Int64,
    manualDebug: Bool
): Unit {
    if (manualDebug) {
        let resolved = tyId.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)
        if (!ctx.allowlistedItems.getOrThrow().contains(resolved.id)) {
            statements.add(tokenStreamFromTemplate("output += \"<blocklisted>\""))
            return
        }
    }
    let ty = ctx.resolveType(tyId)
    match (ty.kind) {
        case TypeKind.ResolvedTypeRef(inner) =>
            appendDebugValue(ctx, inner, expression, statements, depth, manualDebug)
        case TypeKind.TypeKindAlias(inner) =>
            appendDebugValue(ctx, inner, expression, statements, depth, manualDebug)
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            appendDebugValue(ctx, inner, expression, statements, depth, manualDebug)
        case TypeKind.TypeKindArray(inner, length) =>
            appendDebugArray(ctx, inner, length, expression, statements, depth, manualDebug)
        case TypeKind.TypeKindVector(inner, length) =>
            appendDebugArray(ctx, inner, length, expression, statements, depth, manualDebug)
        case TypeKind.TypeKindFunction(_) | TypeKind.TypeKindObjCBlockPointer(_) =>
            statements.add(tokenStreamFromTemplate(
                "output += CPointer<Unit>(${expression}).toUIntNative().toString()"
            ))
        case TypeKind.TypeKindOpaque | TypeKind.TypeKindComplex(_) =>
            statements.add(tokenStreamFromTemplate("output += \"<opaque>\""))
        case TypeKind.TypeKindFloat(_) =>
            if (isOpaqueFloat(ty, ctx)) {
                statements.add(tokenStreamFromTemplate("output += \"<opaque float>\""))
            } else {
                statements.add(tokenStreamFromTemplate("output += ${expression}.toString()"))
            }
        case TypeKind.TypeKindEnum(_) =>
            if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
                statements.add(tokenStreamFromTemplate("output += ${expression}.rawValue.toString()"))
            } else {
                statements.add(tokenStreamFromTemplate("output += ${expression}.toString()"))
            }
        case TypeKind.TypeKindPointer(_) | TypeKind.TypeKindReference(_) |
            TypeKind.TypeKindObjCId | TypeKind.TypeKindObjCSel |
            TypeKind.TypeKindNullPtr | TypeKind.TypeKindObjCInterface(_) =>
            statements.add(tokenStreamFromTemplate(
                "output += CPointer<Unit>(${expression}).toUIntNative().toString()"
            ))
        case TypeKind.TypeKindVoid | TypeKind.TypeKindInt(_) |
            TypeKind.TypeKindComp(_) | TypeKind.TypeKindTemplateInstantiation(_) =>
            statements.add(tokenStreamFromTemplate("output += ${expression}.toString()"))
        case TypeKind.TypeKindTypeParam =>
            statements.add(tokenStreamFromTemplate("output += \"<type parameter>\""))
        case TypeKind.UnresolvedTypeRef(_, _, _) =>
            statements.add(tokenStreamFromTemplate("output += \"<unresolved>\""))
    }
}

func appendDebugArray(
    ctx: CjbindContext,
    inner: TypeId,
    length: UIntNative,
    expression: String,
    statements: ArrayList<TokenStream>,
    depth: Int64,
    manualDebug: Bool
): Unit {
            if (length == 0) {
                statements.add(tokenStreamFromTemplate("output += \"<incomplete array>\""))
                return
            }
            let index = "__cjbindDebugIndex${depth}"
            statements.add(tokenStreamFromTemplate("output += \"[\""))
            let nested = ArrayList<TokenStream>()
            appendDebugValue(ctx, inner, "${expression}[${index}]", nested, depth + 1, manualDebug)
            let nestedBody = joinStreams(nested, "\n")
            let separator = tokenStreamFromTemplate("\", \"")
            statements.add(@tmpl(
                for (${index} in 0..${length}) {
                    if (${index} != 0) {
                        output += ${separator}
                    }
                    ${nestedBody}
                }
            ))
            statements.add(tokenStreamFromTemplate("output += \"]\""))
}

func appendBlobEquality(
    statements: ArrayList<TokenStream>,
    left: String,
    right: String,
    layout: Layout,
    depth: Int64
): Unit {
    let dataLen = layout.opaque().arraySize().getOrDefault({=> layout.size})
    if (dataLen == 1) {
        statements.add(tokenStreamFromTemplate("if (${left} != ${right}) { return false }"))
        return
    }
    let index = "__cjbindEqIndex${depth}"
    statements.add(@tmpl(
        for (${index} in 0..${dataLen}) {
            if (${left}[${index}] != ${right}[${index}]) {
                return false
            }
        }
    ))
}

func appendEqualityCheck(
    ctx: CjbindContext,
    tyId: TypeId,
    left: String,
    right: String,
    statements: ArrayList<TokenStream>,
    depth: Int64
): Bool {
    let ty = ctx.resolveType(tyId)
    return match (ty.kind) {
        case TypeKind.ResolvedTypeRef(inner) =>
            appendEqualityCheck(ctx, inner, left, right, statements, depth)
        case TypeKind.TypeKindAlias(inner) =>
            appendEqualityCheck(ctx, inner, left, right, statements, depth)
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            appendEqualityCheck(ctx, inner, left, right, statements, depth)
        case TypeKind.TypeKindArray(inner, length) =>
            appendArrayEqualityCheck(ctx, inner, length, left, right, statements, depth)
        case TypeKind.TypeKindVector(inner, length) =>
            appendArrayEqualityCheck(ctx, inner, length, left, right, statements, depth)
        case TypeKind.TypeKindOpaque | TypeKind.TypeKindComplex(_) =>
            match (ty.getLayout(ctx)) {
                case Some(layout) =>
                    appendBlobEquality(statements, left, right, layout, depth)
                    true
                case None => false
            }
        case TypeKind.TypeKindFloat(_) =>
            if (isOpaqueFloat(ty, ctx)) {
                match (ty.getLayout(ctx)) {
                    case Some(layout) =>
                        appendBlobEquality(statements, left, right, layout, depth)
                        true
                    case None => false
                }
            } else {
                statements.add(tokenStreamFromTemplate("if (${left} != ${right}) { return false }"))
                true
            }
        case TypeKind.TypeKindFunction(_) | TypeKind.TypeKindObjCBlockPointer(_) =>
            statements.add(tokenStreamFromTemplate(
                "if (CPointer<Unit>(${left}).toUIntNative() != CPointer<Unit>(${right}).toUIntNative()) { return false }"
            ))
            true
        case TypeKind.TypeKindPointer(_) | TypeKind.TypeKindReference(_) |
            TypeKind.TypeKindObjCId | TypeKind.TypeKindObjCSel |
            TypeKind.TypeKindNullPtr | TypeKind.TypeKindObjCInterface(_) =>
            statements.add(tokenStreamFromTemplate(
                "if (CPointer<Unit>(${left}).toUIntNative() != CPointer<Unit>(${right}).toUIntNative()) { return false }"
            ))
            true
        case TypeKind.UnresolvedTypeRef(_, _, _) | TypeKind.TypeKindVoid |
            TypeKind.TypeKindTypeParam => false
        case _ =>
            statements.add(tokenStreamFromTemplate("if (${left} != ${right}) { return false }"))
            true
    }
}

func appendArrayEqualityCheck(
    ctx: CjbindContext,
    inner: TypeId,
    length: UIntNative,
    left: String,
    right: String,
    statements: ArrayList<TokenStream>,
    depth: Int64
): Bool {
            if (length == 0) {
                return false
            }
            let index = "__cjbindEqIndex${depth}"
            let nested = ArrayList<TokenStream>()
            if (!appendEqualityCheck(ctx, inner, "${left}[${index}]", "${right}[${index}]", nested, depth + 1)) {
                return false
            }
            let body = joinStreams(nested, "\n")
            statements.add(@tmpl(
                for (${index} in 0..${length}) {
                    ${body}
                }
            ))
            true
}

func appendBlobHash(
    statements: ArrayList<TokenStream>,
    expression: String,
    layout: Layout,
    depth: Int64
): Unit {
    let dataLen = layout.opaque().arraySize().getOrDefault({=> layout.size})
    if (dataLen == 1) {
        statements.add(tokenStreamFromTemplate(
            "hash = ((hash << 5) | (hash >> 59)) ^ ${expression}.hashCode()"
        ))
        return
    }
    let index = "__cjbindHashIndex${depth}"
    statements.add(@tmpl(
        for (${index} in 0..${dataLen}) {
            hash = ((hash << 5) | (hash >> 59)) ^ ${expression}[${index}].hashCode()
        }
    ))
}

func appendHashValue(
    ctx: CjbindContext,
    tyId: TypeId,
    expression: String,
    statements: ArrayList<TokenStream>,
    depth: Int64
): Bool {
    let ty = ctx.resolveType(tyId)
    return match (ty.kind) {
        case TypeKind.ResolvedTypeRef(inner) =>
            appendHashValue(ctx, inner, expression, statements, depth)
        case TypeKind.TypeKindAlias(inner) =>
            appendHashValue(ctx, inner, expression, statements, depth)
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            appendHashValue(ctx, inner, expression, statements, depth)
        case TypeKind.TypeKindArray(inner, length) =>
            appendArrayHash(ctx, inner, length, expression, statements, depth)
        case TypeKind.TypeKindVector(inner, length) =>
            appendArrayHash(ctx, inner, length, expression, statements, depth)
        case TypeKind.TypeKindOpaque | TypeKind.TypeKindComplex(_) =>
            match (ty.getLayout(ctx)) {
                case Some(value) =>
                    appendBlobHash(statements, expression, value, depth)
                    true
                case None => false
            }
        case TypeKind.TypeKindFunction(_) | TypeKind.TypeKindPointer(_) |
            TypeKind.TypeKindReference(_) | TypeKind.TypeKindObjCBlockPointer(_) |
            TypeKind.TypeKindObjCId | TypeKind.TypeKindObjCSel |
            TypeKind.TypeKindObjCInterface(_) =>
            statements.add(tokenStreamFromTemplate(
                "hash = ((hash << 5) | (hash >> 59)) ^ CPointer<Unit>(${expression}).toUIntNative().hashCode()"
            ))
            true
        case TypeKind.TypeKindEnum(_) =>
            let value = if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
                "${expression}.rawValue"
            } else {
                expression
            }
            statements.add(tokenStreamFromTemplate(
                "hash = ((hash << 5) | (hash >> 59)) ^ ${value}.hashCode()"
            ))
            true
        case TypeKind.TypeKindFloat(_) | TypeKind.UnresolvedTypeRef(_, _, _) |
            TypeKind.TypeKindVoid | TypeKind.TypeKindTypeParam => false
        case _ =>
            statements.add(tokenStreamFromTemplate(
                "hash = ((hash << 5) | (hash >> 59)) ^ ${expression}.hashCode()"
            ))
            true
    }
}

func appendArrayHash(
    ctx: CjbindContext,
    inner: TypeId,
    length: UIntNative,
    expression: String,
    statements: ArrayList<TokenStream>,
    depth: Int64
): Bool {
    if (length == 0) {
        return false
    }
    let index = "__cjbindHashIndex${depth}"
    let nested = ArrayList<TokenStream>()
    if (!appendHashValue(ctx, inner, "${expression}[${index}]", nested, depth + 1)) {
        return false
    }
    let body = joinStreams(nested, "\n")
    statements.add(@tmpl(
        for (${index} in 0..${length}) {
            ${body}
        }
    ))
    return true
}

func appendScalarOrdering(
    statements: ArrayList<TokenStream>,
    left: String,
    right: String
): Unit {
    statements.add(tokenStreamFromTemplate("if (${left} < ${right}) { return Some(Ordering.LT) }"))
    statements.add(tokenStreamFromTemplate("if (${left} > ${right}) { return Some(Ordering.GT) }"))
    statements.add(tokenStreamFromTemplate("if (${left} != ${right}) { return None }"))
}

func appendBlobOrdering(
    statements: ArrayList<TokenStream>,
    left: String,
    right: String,
    layout: Layout,
    depth: Int64
): Unit {
    let dataLen = layout.opaque().arraySize().getOrDefault({=> layout.size})
    if (dataLen == 1) {
        appendScalarOrdering(statements, left, right)
        return
    }
    let index = "__cjbindOrdIndex${depth}"
    statements.add(@tmpl(
        for (${index} in 0..${dataLen}) {
            if (${left}[${index}] < ${right}[${index}]) {
                return Some(Ordering.LT)
            }
            if (${left}[${index}] > ${right}[${index}]) {
                return Some(Ordering.GT)
            }
        }
    ))
}

func appendOrderingValue(
    ctx: CjbindContext,
    tyId: TypeId,
    left: String,
    right: String,
    statements: ArrayList<TokenStream>,
    depth: Int64
): Bool {
    let ty = ctx.resolveType(tyId)
    return match (ty.kind) {
        case TypeKind.ResolvedTypeRef(inner) =>
            appendOrderingValue(ctx, inner, left, right, statements, depth)
        case TypeKind.TypeKindAlias(inner) =>
            appendOrderingValue(ctx, inner, left, right, statements, depth)
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            appendOrderingValue(ctx, inner, left, right, statements, depth)
        case TypeKind.TypeKindArray(inner, length) =>
            appendArrayOrdering(ctx, inner, length, left, right, statements, depth)
        case TypeKind.TypeKindVector(inner, length) =>
            appendArrayOrdering(ctx, inner, length, left, right, statements, depth)
        case TypeKind.TypeKindOpaque | TypeKind.TypeKindComplex(_) =>
            match (ty.getLayout(ctx)) {
                case Some(value) =>
                    appendBlobOrdering(statements, left, right, value, depth)
                    true
                case None => false
            }
        case TypeKind.TypeKindInt(TypeKindIntKind.IntKindBool) =>
            statements.add(tokenStreamFromTemplate(
                "if (!${left} && ${right}) { return Some(Ordering.LT) }"
            ))
            statements.add(tokenStreamFromTemplate(
                "if (${left} && !${right}) { return Some(Ordering.GT) }"
            ))
            true
        case TypeKind.TypeKindFunction(_) | TypeKind.TypeKindPointer(_) |
            TypeKind.TypeKindReference(_) | TypeKind.TypeKindObjCBlockPointer(_) |
            TypeKind.TypeKindObjCId | TypeKind.TypeKindObjCSel | TypeKind.TypeKindNullPtr |
            TypeKind.TypeKindObjCInterface(_) =>
            appendScalarOrdering(
                statements,
                "CPointer<Unit>(${left}).toUIntNative()",
                "CPointer<Unit>(${right}).toUIntNative()"
            )
            true
        case TypeKind.TypeKindEnum(_) =>
            if (ctx.options.defaultEnumStyle == DefaultEnumStyle.NewType) {
                appendScalarOrdering(statements, "${left}.rawValue", "${right}.rawValue")
            } else {
                appendScalarOrdering(statements, left, right)
            }
            true
        case TypeKind.TypeKindFloat(_) =>
            if (isOpaqueFloat(ty, ctx)) {
                match (ty.getLayout(ctx)) {
                    case Some(layout) =>
                        appendBlobOrdering(statements, left, right, layout, depth)
                        true
                    case None => false
                }
            } else {
                appendScalarOrdering(statements, left, right)
                true
            }
        case TypeKind.UnresolvedTypeRef(_, _, _) | TypeKind.TypeKindVoid |
            TypeKind.TypeKindTypeParam => false
        case TypeKind.TypeKindComp(_) =>
            let resolved = tyId.intoResolver().throughTypeRefs().throughTypeAliases().resolve(ctx)
            if (ctx.allowlistedItems.getOrThrow().contains(resolved.id)) {
                statements.add(@tmpl(
                    match (${left}.__cjbindPartialCompare(${right})) {
                        case Some(Ordering.LT) => return Some(Ordering.LT)
                        case Some(Ordering.GT) => return Some(Ordering.GT)
                        case None => return None
                        case _ => ()
                    }
                ))
            } else {
                appendScalarOrdering(statements, left, right)
            }
            true
        case _ =>
            appendScalarOrdering(statements, left, right)
            true
    }
}

func appendArrayOrdering(
    ctx: CjbindContext,
    inner: TypeId,
    length: UIntNative,
    left: String,
    right: String,
    statements: ArrayList<TokenStream>,
    depth: Int64
): Bool {
    if (length == 0) {
        return false
    }
    let index = "__cjbindOrdIndex${depth}"
    let nested = ArrayList<TokenStream>()
    if (!appendOrderingValue(
        ctx, inner, "${left}[${index}]", "${right}[${index}]", nested, depth + 1
    )) {
        return false
    }
    let body = joinStreams(nested, "\n")
    statements.add(@tmpl(
        for (${index} in 0..${length}) {
            ${body}
        }
    ))
    return true
}

func codegenDerivedCoreMembers(
    ctx: CjbindContext,
    item: Item,
    comp: CompInfo,
    typeIdent: String,
    isOpaque: Bool,
    layout: ?Layout
): Array<TokenStream> {
    let members = ArrayList<TokenStream>()

    if (ctx.options.deriveCopy && !ctx.noDeriveByName(item, DeriveTrait.Copy)) {
        if (ctx.canDerive(item.id, DeriveTrait.Copy) == CanDerive.Yes &&
            !ctx.hasTypeParameterInArray(item.id)) {
            if (derivedMemberNameConflicts(ctx, comp, isOpaque, "clone")) {
                deriveWarning(ctx, item, "clone", "a generated record member already uses the name 'clone'")
            } else {
                members.add(tokenStreamFromTemplate(
                    "public func clone(): ${typeIdent} { return this }"
                ))
            }
        } else {
            deriveWarning(ctx, item, "clone", "Copy analysis rejected this record")
        }
    }

    if (ctx.options.deriveDebug && !ctx.noDeriveByName(item, DeriveTrait.Debug)) {
        let decision = ctx.canDerive(item.id, DeriveTrait.Debug)
        let enabled = decision == CanDerive.Yes || ctx.options.implDebug
        let manualDebug = decision != CanDerive.Yes
        let conflict = compHasGeneratedCapabilityConflict(
            ctx,
            item,
            comp,
            GeneratedDerivedCapability.Debug,
            HashSet<ItemId>()
        )
        if (enabled && conflict) {
            deriveWarning(
                ctx,
                item,
                "toString",
                "this record or a dependency already uses the generated member name 'toString'"
            )
        } else if (enabled) {
            let statements = ArrayList<TokenStream>()
            statements.add(tokenStreamFromTemplate("var output = \"${typeIdent} {\""))
            if (isOpaque) {
                statements.add(tokenStreamFromTemplate("output += \" <opaque>\""))
            } else if (comp.isUnion()) {
                statements.add(tokenStreamFromTemplate("output += \" <union>\""))
            } else {
                var first = true
                for (value in derivedValues(ctx, item, comp)) {
                    if (manualDebug) {
                        let skip = match (value.ty) {
                            case Some(ty) =>
                                let resolved = ty.intoResolver()
                                    .throughTypeRefs()
                                    .throughTypeAliases()
                                    .resolve(ctx)
                                !ctx.allowlistedItems.getOrThrow().contains(resolved.id)
                            case None => false
                        }
                        if (skip) {
                            continue
                        }
                    }
                    let separator = if (first) { " " } else { ", " }
                    first = false
                    statements.add(tokenStreamFromTemplate("output += \"${separator}${value.label}: \""))
                    match (value.ty) {
                        case Some(ty) => appendDebugValue(
                            ctx, ty, value.left, statements, 0, manualDebug
                        )
                        case None => statements.add(tokenStreamFromTemplate(
                            "output += CPointer<Unit>(${value.left}).toUIntNative().toString()"
                        ))
                    }
                }
            }
            statements.add(tokenStreamFromTemplate("output += \" }\""))
            statements.add(tokenStreamFromTemplate("return output"))
            let body = joinStreams(statements, "\n")
            members.add(@tmpl(
                public func toString(): String {
                    ${body}
                }
            ))
        } else {
            let reason = "manual Debug generation requires --impl-debug"
            deriveWarning(ctx, item, "toString", reason)
        }
    }

    if (ctx.options.derivePartialEq &&
        !ctx.noDeriveByName(item, DeriveTrait.PartialEqOrPartialOrd)) {
        let decision = ctx.canDerive(item.id, DeriveTrait.PartialEqOrPartialOrd)
        let enabled = decision == CanDerive.Yes ||
            (decision == CanDerive.Manually && ctx.options.implPartialEq)
        if (enabled) {
            let statements = ArrayList<TokenStream>()
            var safe = true
            if (isOpaque) {
                match (layout) {
                    case Some(value) => appendBlobEquality(
                        statements, "this._cjbind_opaque_blob", "right._cjbind_opaque_blob", value, 0
                    )
                    case None => safe = false
                }
            } else if (comp.isUnion()) {
                match (layout) {
                    case Some(value) => appendBlobEquality(statements, "this._storage", "right._storage", value, 0)
                    case None => safe = false
                }
            } else {
                for (value in derivedValues(ctx, item, comp)) {
                    match (value.ty) {
                        case Some(ty) =>
                            if (!appendEqualityCheck(ctx, ty, value.left, value.right, statements, 0)) {
                                safe = false
                            }
                        case None => statements.add(tokenStreamFromTemplate(
                            "if (CPointer<Unit>(${value.left}).toUIntNative() != CPointer<Unit>(${value.right}).toUIntNative()) { return false }"
                        ))
                    }
                }
            }
            if (safe) {
                statements.add(tokenStreamFromTemplate("return true"))
                let body = joinStreams(statements, "\n")
                members.add(@tmpl(
                    public operator func ==(right: ${typeIdent}): Bool {
                        ${body}
                    }
                ))
                members.add(tokenStreamFromTemplate(
                    "public operator func !=(right: ${typeIdent}): Bool { return !(this == right) }"
                ))
            } else {
                deriveWarning(ctx, item, "equality operators", "one or more fields cannot be compared safely")
            }
        } else {
            let reason = if (decision == CanDerive.Manually) {
                "manual PartialEq generation requires --impl-partialeq"
            } else {
                "PartialEq analysis rejected this record"
            }
            deriveWarning(ctx, item, "equality operators", reason)
        }
    }
    if (ctx.options.deriveEq &&
        !ctx.noDeriveByName(item, DeriveTrait.PartialEqOrPartialOrd) &&
        !ctx.canDeriveEq(item.id)) {
        deriveWarning(
            ctx,
            item,
            "Eq guarantee",
            "this record does not satisfy a total equality relation"
        )
    }
    return members.toArray()
}

func codegenDerivedDefaultAndHashMembers(
    ctx: CjbindContext,
    item: Item,
    comp: CompInfo,
    typeIdent: String,
    isOpaque: Bool,
    layout: ?Layout
): Array<TokenStream> {
    let members = ArrayList<TokenStream>()
    if (ctx.options.deriveDefault && !ctx.noDeriveByName(item, DeriveTrait.Default)) {
        let decision = ctx.canDerive(item.id, DeriveTrait.Default)
        if (decision != CanDerive.Yes) {
            let reason = if (decision == CanDerive.Manually) {
                "Default analysis requires a manual implementation"
            } else {
                "Default analysis rejected this record"
            }
            deriveWarning(ctx, item, "default", reason)
        } else if (!comp.isForwardDeclaration) {
            if (derivedMemberNameConflicts(ctx, comp, isOpaque, "default")) {
                deriveWarning(ctx, item, "default", "a generated record member already uses the name 'default'")
            } else {
                members.add(tokenStreamFromTemplate(
                    "public static func default(): ${typeIdent} { return unsafe { zeroValue<${typeIdent}>() } }"
                ))
            }
        } else {
            deriveWarning(ctx, item, "default", "forward declarations cannot be initialized")
        }
    }

    if (ctx.options.deriveHash && !ctx.noDeriveByName(item, DeriveTrait.Hash)) {
        let conflict = compHasGeneratedCapabilityConflict(
            ctx,
            item,
            comp,
            GeneratedDerivedCapability.Hash,
            HashSet<ItemId>()
        )
        if (ctx.canDerive(item.id, DeriveTrait.Hash) == CanDerive.Yes && conflict) {
            deriveWarning(
                ctx,
                item,
                "hashCode",
                "this record or a dependency already uses the generated member name 'hashCode'"
            )
        } else if (ctx.canDerive(item.id, DeriveTrait.Hash) == CanDerive.Yes) {
            let statements = ArrayList<TokenStream>()
            statements.add(tokenStreamFromTemplate("var hash = 1469598103934665603i64"))
            var safe = true
            if (isOpaque) {
                match (layout) {
                    case Some(value) => appendBlobHash(statements, "this._cjbind_opaque_blob", value, 0)
                    case None => safe = false
                }
            } else if (comp.isUnion()) {
                match (layout) {
                    case Some(value) => appendBlobHash(statements, "this._storage", value, 0)
                    case None => safe = false
                }
            } else {
                for (value in derivedValues(ctx, item, comp)) {
                    match (value.ty) {
                        case Some(ty) =>
                            if (!appendHashValue(ctx, ty, value.left, statements, 0)) {
                                safe = false
                            }
                        case None => statements.add(tokenStreamFromTemplate(
                            "hash = ((hash << 5) | (hash >> 59)) ^ CPointer<Unit>(${value.left}).toUIntNative().hashCode()"
                        ))
                    }
                }
            }
            if (safe) {
                statements.add(tokenStreamFromTemplate("return hash"))
                let body = joinStreams(statements, "\n")
                members.add(@tmpl(
                    public func hashCode(): Int64 {
                        ${body}
                    }
                ))
            } else {
                deriveWarning(ctx, item, "hashCode", "one or more fields cannot be hashed safely")
            }
        } else {
            deriveWarning(ctx, item, "hashCode", "Hash analysis rejected this record")
        }
    }
    return members.toArray()
}

func codegenDerivedOrderingMembers(
    ctx: CjbindContext,
    item: Item,
    comp: CompInfo,
    typeIdent: String,
    isOpaque: Bool,
    layout: ?Layout
): Array<TokenStream> {
    let members = ArrayList<TokenStream>()
    if (!ctx.options.derivePartialOrd ||
        ctx.noDeriveByName(item, DeriveTrait.PartialEqOrPartialOrd)) {
        return members.toArray()
    }

    let decision = ctx.canDerive(item.id, DeriveTrait.PartialEqOrPartialOrd)
    let enabled = decision == CanDerive.Yes
    if (!enabled) {
        deriveWarning(ctx, item, "ordering operators", "PartialOrd analysis rejected this record")
        return members.toArray()
    }
    if (compHasGeneratedCapabilityConflict(
        ctx,
        item,
        comp,
        GeneratedDerivedCapability.Ordering,
        HashSet<ItemId>()
    )) {
        deriveWarning(
            ctx,
            item,
            "ordering operators",
            "this record or a dependency already uses the generated member name '__cjbindPartialCompare'"
        )
        return members.toArray()
    }

    let statements = ArrayList<TokenStream>()
    var safe = true
    if (isOpaque) {
        match (layout) {
            case Some(value) => appendBlobOrdering(
                statements, "this._cjbind_opaque_blob", "right._cjbind_opaque_blob", value, 0
            )
            case None => safe = false
        }
    } else if (comp.isUnion()) {
        match (layout) {
            case Some(value) => appendBlobOrdering(statements, "this._storage", "right._storage", value, 0)
            case None => safe = false
        }
    } else {
        for (value in derivedValues(ctx, item, comp)) {
            match (value.ty) {
                case Some(ty) =>
                    if (!appendOrderingValue(ctx, ty, value.left, value.right, statements, 0)) {
                        safe = false
                    }
                case None => appendScalarOrdering(
                    statements,
                    "CPointer<Unit>(${value.left}).toUIntNative()",
                    "CPointer<Unit>(${value.right}).toUIntNative()"
                )
            }
        }
    }
    if (!safe) {
        deriveWarning(ctx, item, "ordering operators", "one or more fields cannot be ordered safely")
        return members.toArray()
    }

    statements.add(tokenStreamFromTemplate("return Some(Ordering.EQ)"))
    let body = joinStreams(statements, "\n")
    members.add(@tmpl(
        public func __cjbindPartialCompare(right: ${typeIdent}): ?Ordering {
            ${body}
        }
    ))
    members.add(@tmpl(
        public operator func <(right: ${typeIdent}): Bool {
            return match (this.__cjbindPartialCompare(right)) {
                case Some(Ordering.LT) => true
                case _ => false
            }
        }
    ))
    members.add(@tmpl(
        public operator func <=(right: ${typeIdent}): Bool {
            return match (this.__cjbindPartialCompare(right)) {
                case Some(Ordering.LT) | Some(Ordering.EQ) => true
                case _ => false
            }
        }
    ))
    members.add(@tmpl(
        public operator func >(right: ${typeIdent}): Bool {
            return match (this.__cjbindPartialCompare(right)) {
                case Some(Ordering.GT) => true
                case _ => false
            }
        }
    ))
    members.add(@tmpl(
        public operator func >=(right: ${typeIdent}): Bool {
            return match (this.__cjbindPartialCompare(right)) {
                case Some(Ordering.GT) | Some(Ordering.EQ) => true
                case _ => false
            }
        }
    ))

    if (ctx.options.deriveOrd) {
        if (ctx.canDeriveOrd(item.id) &&
            derivedMemberNameConflicts(ctx, comp, isOpaque, "compare")) {
            deriveWarning(ctx, item, "compare", "a generated record member already uses the name 'compare'")
        } else if (ctx.canDeriveOrd(item.id)) {
            let unorderedError = tokenStreamFromTemplate(
                "\"ordered comparison produced an unordered value\""
            )
            members.add(@tmpl(
                public func compare(right: ${typeIdent}): Ordering {
                    return match (this.__cjbindPartialCompare(right)) {
                        case Some(value) => value
                        case None => throw Exception(${unorderedError})
                    }
                }
            ))
        } else {
            deriveWarning(ctx, item, "compare", "Ord requires every field to have a total order")
        }
    }
    return members.toArray()
}
