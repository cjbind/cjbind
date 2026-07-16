package cjbind.codegen

import cjbind_token.*
import cjbind.ir.*
import cjbind.result.{Result}
import std.collection.{ArrayList, HashMap}

func templateInstantiationUsesOpaqueBlob(ctx: CjbindContext, item: Item): Bool {
    if (ctx.templateInstantiationFor(item.id).isSome() && item.isSemanticallyOpaque(ctx)) {
        return true
    }
    let ty = item.kind.expectType()
    let instantiation = match (ty.kind) {
        case TypeKind.TypeKindTemplateInstantiation(value) => value
        case _ => return false
    }
    if (!instantiation.argumentsComplete) {
        return true
    }
    let definition = instantiation.definition
        .intoResolver()
        .throughTypeRefs()
        .resolve(ctx)
    if (ctx.isBlocklistedItem(definition.id)) {
        return true
    }
    let definitionKind = definition.kind.expectType().kind
    // Class-template partial specializations are deliberately represented as
    // opaque definitions in the IR.  Their unqualified spelling may collide
    // with an emitted primary template, but that primary has a different C++
    // layout.  Keep the concrete specialization as a layout-sized blob until
    // it can be materialized safely instead of referring to that basename.
    if (let TypeKind.TypeKindOpaque <- definitionKind) {
        return true
    }
    let definitionIsComp = match (definitionKind) {
        case TypeKind.TypeKindComp(_) => true
        case _ => false
    }
    // An unmaterialized class-template specialization must never be rendered
    // as the primary-template basename.  Its own layout is the only safe ABI
    // representation, regardless of usedTemplateParams analysis.
    return ctx.codegenTemplateReplacement(item.id).isNone() && definitionIsComp
}

// 实现时应该添加对于 ToOpaque 的实现
interface TryToOpaque<Extra> {
    func tryGetLayout(
        ctx: CjbindContext,
        extra: Extra
    ): Result<Layout, Error>

    func tryToOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): Result<TokenStream, Error> {
        this.tryGetLayout(ctx, extra).map {
            layout => return Helpers.blob(ctx, layout)
        }
    }
}

interface ToOpaque<Extra> <: TryToOpaque<Extra> {
    func getLayoutUnsafe(
        ctx: CjbindContext,
        extra: Extra
    ): Layout {
        this.tryGetLayout(ctx, extra).unwrapOrElse {
            _ => return Layout.forSize(ctx, 1)
        }
    }

    func toOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): TokenStream {
        let layout = this.getLayoutUnsafe(ctx, extra)
        Helpers.blob(ctx, layout)
    }
}

interface TryToCjTy<Extra> {
    func tryToCjTy(
        ctx: CjbindContext,
        extra: Extra
    ): Result<TokenStream, Error>
}

interface TryToCjTyOrOpaque<Extra> <: TryToCjTy<Extra> & TryToOpaque<Extra> {
    func tryToCjTyOrOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): Result<TokenStream, Error> {
        this
            .tryToCjTy(ctx, extra)
            .orElse {
                _ => if (let Ok(layout) <- this.tryGetLayout(ctx, extra)) {
                    Ok(Helpers.blob(ctx, layout))
                } else {
                    Err(Error.NoLayoutForOpaqueBlob)
                }
            }
    }
}

interface ToCjTyOrOpaque<Extra> <: TryToCjTy<Extra> & ToOpaque<Extra> {
    func toCjTyOrOpaque(
        ctx: CjbindContext,
        extra: Extra
    ): TokenStream {
        this.tryToCjTy(ctx, extra).unwrapOrElse {
            _ => this.toOpaque(ctx, extra)
        }
    }
}

extend ItemId <: TryToCjTy<Unit> {
    public func tryToCjTy(
        ctx: CjbindContext,
        _: Unit
    ): Result<TokenStream, Error> {
        return ctx.resolveItem(this).tryToCjTy(ctx, ())
    }
}

extend ItemId <: TryToOpaque<Unit> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Unit
    ): Result<Layout, Error> {
        return ctx.resolveItem(this).tryGetLayout(ctx, ())
    }
}

extend ItemId <: ToOpaque<Unit> {}

extend ItemId <: ToCjTyOrOpaque<Unit> & TryToCjTyOrOpaque<Unit> {}

extend Item <: TryToCjTy<Unit> {
    public func tryToCjTy(
        ctx: CjbindContext,
        _: Unit
    ): Result<TokenStream, Error> {
        return this.kind.expectType().tryToCjTy(ctx, this)
    }
}

extend Item <: TryToOpaque<Unit> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Unit
    ): Result<Layout, Error> {
        return this.kind.expectType().tryGetLayout(ctx, this)
    }
}

extend Item <: ToCjTyOrOpaque<Unit> & TryToCjTyOrOpaque<Unit> {}

extend Type <: TryToCjTy<Item> {
    // cjlint-ignore -start !G.FUN.01
    public func tryToCjTy(
        ctx: CjbindContext,
        item: Item
    ): Result<TokenStream, Error> {
        if (let Some((definitionId, concreteArguments)) <- ctx.codegenAliasUse(item.id)) {
            let definition = ctx.resolveItem(definitionId)
            let name = ctx.cjIdentRaw(definition.canonicalName(ctx))
            if (definition.isOpaque(ctx, ())) {
                return Ok(tokenStreamFromTemplate(name))
            }
            let definitionInner: ?TypeId = match (definition.kind.expectType().kind) {
                case TypeKind.TypeKindAlias(inner) => Some(inner)
                case TypeKind.TypeKindTemplateAlias(inner, _) => Some(inner)
                case _ => None
            }
            if (let Some(inner) <- definitionInner) {
                let requiresConcreteRendering = match (validateTemplateAliasDefinition(
                    ctx,
                    definition,
                    inner
                )) {
                    case Ok(exact) => !exact
                    case Err(_) => true
                }
                if (requiresConcreteRendering) {
                    return renderConcreteTemplateAlias(
                        ctx,
                        inner,
                        ctx.usedTemplateParams(definition.id),
                        concreteArguments,
                        HashMap<ItemId, String>(),
                        ItemSet()
                    )
                }
            }
            let arguments = ArrayList<TokenStream>()
            for (argumentId in concreteArguments) {
                match (argumentId.tryToCjTy(ctx, ())) {
                    case Ok(argument) => arguments.add(argument)
                    case Err(error) => return Err(error)
                }
            }
            if (arguments.isEmpty()) {
                return Ok(tokenStreamFromTemplate(name))
            }
            let joined = joinStreams(arguments, ", ")
            return Ok(tokenStreamFromTemplate("${name}<${joined}>"))
        }
        match (this.kind) {
            case TypeKind.TypeKindVoid => return Ok(AstTy.cVoid(ctx))
            case TypeKind.TypeKindNullPtr => return Ok(AstTy.cVoid(ctx).toPtr())
            case TypeKind.TypeKindInt(ik) =>
                let ret = AstTy.intKindCjType(ctx, ik, this.getLayout(ctx))
                return Ok(ret)
            case TypeKind.TypeKindFloat(fk) =>
                let requiresOpaque = match (fk) {
                    case TypeKindFloatKind.FloatKindFloat128 => true
                    case TypeKindFloatKind.FloatKindLongDouble =>
                        this.getLayout(ctx).map({layout => layout.size > 8}).getOrDefault({=> false})
                    case _ => false
                }
                if (requiresOpaque) {
                    return this.tryToOpaque(ctx, item)
                }
                if (let TypeKindFloatKind.FloatKindFloat16 <- fk) {
                    ctx.codegenSawFloat16 = true
                }
                let ret = AstTy.floatKindCjType(ctx, fk, this.getLayout(ctx))
                return Ok(ret)
            case TypeKind.TypeKindComplex(fk) =>
                match (AstTy.complexKindCjType(ctx, fk, this.getLayout(ctx))) {
                    case Some(value) =>
                        ctx.codegenSawComplex = true
                        return Ok(value)
                    case None => return this.tryToOpaque(ctx, item)
                }
            case TypeKind.TypeKindFunction(signature) =>
                let ty = match (signature.tryToCjTy(ctx, item)) {
                    case Ok(v) => v
                    case Err(e) => return Err(e)
                }
                return Ok(ty)
            case TypeKind.TypeKindArray(item, len) =>
                let ty = match (item.tryToCjTy(ctx, ())) {
                    case Ok(v) => v
                    case Err(e) => return Err(e)
                }
                let lenOk = Int64(len)
                let token = tokenStreamFromTemplate("VArray<${ty}, \$${lenOk}>")
                return Ok(token)
            case TypeKind.TypeKindVector(item, len) =>
                let ty = match (item.tryToCjTy(ctx, ())) {
                    case Ok(v) => v
                    case Err(e) => return Err(e)
                }
                let lenOk = Int64(len)
                let token = tokenStreamFromTemplate("VArray<${ty}, \$${lenOk}>")
                return Ok(token)
            case TypeKind.TypeKindEnum(_) => return Ok(tokenStreamFromTemplate(ctx.cjIdentRaw(item.canonicalName(ctx))))
            case TypeKind.ResolvedTypeRef(inner) => return inner.tryToCjTy(ctx, ())
            case TypeKind.TypeKindAlias(_) | TypeKind.TypeKindTemplateAlias(_, _) | TypeKind.TypeKindTypeParam =>
                if (let Some(n) <- this.name) {
                    let named = Utils.typeFromNamed(ctx, n)
                    if (let Some(nn) <- named) {
                        return Ok(nn)
                    }
                }
                return Ok(tokenStreamFromTemplate(ctx.cjIdentRaw(item.canonicalName(ctx))))
            case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
                if (templateInstantiationUsesOpaqueBlob(ctx, item)) {
                    return this.tryToOpaque(ctx, item)
                }
                if (let Some(replacement) <- ctx.codegenTemplateReplacement(item.id)) {
                    return replacement.tryToCjTy(ctx, ())
                }
                let definition = instantiation.definition
                    .intoResolver()
                    .throughTypeRefs()
                    .resolve(ctx)
                if (let TypeKind.TypeKindTemplateAlias(inner, _) <- definition.kind.expectType().kind) {
                    if (definition.isOpaque(ctx, ())) {
                        return Ok(tokenStreamFromTemplate(
                            ctx.cjIdentRaw(definition.canonicalName(ctx))
                        ))
                    }
                    let parameters = selfTemplateParams(definition.id, ctx)
                    let requiresConcreteRendering = match (validateTemplateAliasDefinition(
                        ctx,
                        definition,
                        inner
                    )) {
                        case Ok(exact) => !exact && instantiation.arguments.all {
                            argument => !ctx.usesAnyTemplateParameters(argument)
                        }
                        case Err(_) => true
                    }
                    if (requiresConcreteRendering) {
                        return renderConcreteTemplateAlias(
                            ctx,
                            inner,
                            parameters,
                            instantiation.arguments,
                            HashMap<ItemId, String>(),
                            ItemSet()
                        )
                    }
                    let arguments = ArrayList<TokenStream>()
                    let count = min(parameters.size, instantiation.arguments.size)
                    for (index in 0..count) {
                        let parameter = parameters[index]
                        if (!ctx.usesTemplateParameter(definition.id, parameter)) {
                            continue
                        }
                        let argument = match (instantiation.arguments[index].tryToCjTy(ctx, ())) {
                            case Ok(value) => value
                            case Err(error) => return Err(error)
                        }
                        arguments.add(argument)
                    }
                    let name = ctx.cjIdentRaw(definition.canonicalName(ctx))
                    if (arguments.isEmpty()) {
                        return Ok(tokenStreamFromTemplate(name))
                    }
                    let joined = joinStreams(arguments, ", ")
                    return Ok(tokenStreamFromTemplate("${name}<${joined}>") )
                }
                if (ctx.usedTemplateParams(definition.id).isEmpty()) {
                    return Ok(tokenStreamFromTemplate(ctx.cjIdentRaw(definition.canonicalName(ctx))))
                }
                return Err(Error.Unsupported(
                    "concrete C++ template type was not materialized"
                ))
            case TypeKind.TypeKindComp(info) =>
                let templateParameters = allTemplateParams(item.id, ctx)
                if (info.hasNonTypeTemplateParams ||
                    (item.isOpaque(ctx, ()) && !templateParameters.isEmpty())) {
                    return this.tryToOpaque(ctx, item)
                }
                return Ok(tokenStreamFromTemplate(ctx.cjIdentRaw(item.canonicalName(ctx))))
            case TypeKind.TypeKindOpaque => return this.tryToOpaque(ctx, item)
            case TypeKind.TypeKindReference(inner) =>
                return this.pointerLikeType(ctx, item, inner, false)
            case TypeKind.TypeKindPointer(inner) =>
                return this.pointerLikeType(ctx, item, inner, true)
            case TypeKind.TypeKindObjCId => return Ok(tokenStreamFromTemplate("CPointer<Unit>"))
            case TypeKind.TypeKindObjCSel => return Ok(tokenStreamFromTemplate("CPointer<Unit>"))
            case TypeKind.TypeKindObjCBlockPointer(inner) =>
                // Try to resolve the inner function type for a typed block
                let innerItem = inner.intoResolver().throughTypeRefs().resolve(ctx)
                match (innerItem.kind.asType()) {
                    case Some(innerTy) =>
                        match (innerTy.canonicalType(ctx).kind) {
                            case TypeKind.TypeKindFunction(blockSig) =>
                                // Keep alias newtypes out of the raw callback
                                // ABI here as well; a block invocation cannot
                                // use the public foreign-function wrap/unwrap
                                // shim generated for ordinary declarations.
                                let blockRet = newTypeAbiReturnType(ctx, blockSig)
                                let blockArgs = newTypeAbiArguments(ctx, blockSig)
                                let joinedBlockArgs = joinStreams(blockArgs, ", ")
                                return Ok(tokenStreamFromTemplate("CFunc<(${joinedBlockArgs}) -> ${blockRet}>"))
                            case _ => return Ok(tokenStreamFromTemplate("CPointer<Unit>"))
                        }
                    case None => return Ok(tokenStreamFromTemplate("CPointer<Unit>"))
                }
            case TypeKind.TypeKindObjCInterface(iface) =>
                return Ok(tokenStreamFromTemplate(ctx.cjIdentRaw(iface.name)))
            case TypeKind.UnresolvedTypeRef(_, _, _) => throw Exception("unreachable")
        }
    }

    private func pointerLikeType(
        ctx: CjbindContext,
        item: Item,
        inner: TypeId,
        allowCString: Bool
    ): Result<TokenStream, Error> {
                let size = this.getLayoutUnsafe(ctx, item).size
                if (size != ctx.pointerWidth()) {
                    return Err(
                        Error.InvalidPointerSize(
                            this.name.getOrDefault {=> "unknown"},
                            UIntNative(size),
                            UIntNative(ctx.pointerWidth())
                        )
                    )
                }

                let innerTy = inner.intoResolver().throughTypeRefs().resolve(ctx).kind.expectType()

                let innerCanonicalType = innerTy.canonicalType(ctx)

                if (innerCanonicalType.isFunction()) {
                    return match (inner.tryToCjTy(ctx, ())) {
                        case Ok(ty) => Ok(ty)
                        case Err(Error.UnsupportedAbi(abi)) =>
                            eprintln(
                                "Error: representing a function pointer as CPointer<Unit> because calling convention '${abi}' cannot be represented by the current Cangjie FFI"
                            )
                            Ok(tokenStreamFromTemplate("CPointer<Unit>"))
                        case Err(Error.Unsupported(reason)) =>
                            eprintln(
                                "Warning: representing a function pointer as CPointer<Unit> because ${reason}"
                            )
                            Ok(tokenStreamFromTemplate("CPointer<Unit>"))
                        case Err(_) => Ok(tokenStreamFromTemplate("CPointer<Unit>"))
                    }
                } else if (innerCanonicalType.isChar() && allowCString && ctx.options.autoCString) {
                    return Ok(tokenStreamFromTemplate("CString"))
                } else {
                    let ty = inner.toCjTyOrOpaque(ctx, ())
                    return Ok(ty.toPtr())
                }
    }
    // cjlint-ignore -end
}

extend Type <: TryToOpaque<Item> {
    public func tryGetLayout(
        ctx: CjbindContext,
        _: Item
    ): Result<Layout, Error> {
        match (this.getLayout(ctx)) {
            case Some(v) => Ok(v)
            case None => Err(Error.NoLayoutForOpaqueBlob)
        }
    }
}

extend Type <: ToOpaque<Item> {}
extend Type <: ToCjTyOrOpaque<Item> {}

extend FunctionSig <: TryToCjTy<Item> {
    public func tryToCjTy(
        ctx: CjbindContext,
        _: Item
    ): Result<TokenStream, Error> {
        if (!this.abi.isCFuncCompatibleForTarget(ctx.targetInfo)) {
            return Err(Error.UnsupportedAbi(this.abi.diagnosticName()))
        }
        if (this.valueAbiUnsupported || hasOpaqueValueAbi(this, ctx)) {
            return Err(Error.Unsupported(
                "the function pointer value ABI cannot be represented safely by the current Cangjie FFI"
            ))
        }

        let ret = newTypeAbiReturnType(ctx, this)
        if (this.rawIsVariadic()) {
            ctx.codegenVariadicFunctionArities.add(this.argumentTypes.size)
            let typeArguments = ArrayList<TokenStream>()
            typeArguments.add(ret)
            for ((_, argumentType) in this.argumentTypes) {
                typeArguments.add(newTypeAbiArgumentType(ctx, argumentType))
            }
            let joinedTypeArguments = joinStreams(typeArguments, ", ")
            let typeName = Helpers.variadicFunctionTypeName(this.argumentTypes.size)
            return Ok(tokenStreamFromTemplate("${typeName}<${joinedTypeArguments}>") )
        }
        let arguments = newTypeAbiArguments(ctx, this)

        let joined = joinStreams(arguments, ", ")

        let retToken = tokenStreamFromTemplate("CFunc<(${joined}) -> ${ret}>")
        return Ok(retToken)
    }
}
