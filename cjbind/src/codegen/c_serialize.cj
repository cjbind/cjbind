package cjbind.codegen

import std.collection.ArrayList
import std.env.getTempDirectory
import std.fs.{Directory, File, Path, canonicalize, exists}

import cjbind.ir.*
import cjbind.result.Result

/// A function selected for emission into the C/C++ static-wrapper source.
public class StaticWrapper {
    public let itemId: ItemId
    public let symbolName: String

    public init(itemId: ItemId, symbolName: String) {
        this.itemId = itemId
        this.symbolName = symbolName
    }
}

func sourceTypeHasIncompleteTemplateIdentity(
    ctx: CjbindContext,
    typeId: TypeId,
    visiting: ItemSet
): Bool {
    if (!visiting.add(typeId)) {
        return false
    }
    let ty = ctx.resolveType(typeId)
    return match (ty.kind) {
        case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
            !instantiation.argumentsComplete || instantiation.arguments.any {
                argument => sourceTypeHasIncompleteTemplateIdentity(ctx, argument, visiting)
            }
        case TypeKind.TypeKindPointer(inner) =>
            sourceTypeHasIncompleteTemplateIdentity(ctx, inner, visiting)
        case TypeKind.TypeKindReference(inner) =>
            sourceTypeHasIncompleteTemplateIdentity(ctx, inner, visiting)
        case TypeKind.TypeKindArray(inner, _) =>
            sourceTypeHasIncompleteTemplateIdentity(ctx, inner, visiting)
        case TypeKind.TypeKindVector(inner, _) =>
            sourceTypeHasIncompleteTemplateIdentity(ctx, inner, visiting)
        case TypeKind.TypeKindAlias(inner) =>
            sourceTypeHasIncompleteTemplateIdentity(ctx, inner, visiting)
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            sourceTypeHasIncompleteTemplateIdentity(ctx, inner, visiting)
        case TypeKind.ResolvedTypeRef(inner) =>
            sourceTypeHasIncompleteTemplateIdentity(ctx, inner, visiting)
        case TypeKind.TypeKindFunction(signature) =>
            staticWrapperSignatureHasIncompleteTemplateIdentity(
                ctx,
                signature,
                visiting: visiting
            )
        case _ => false
    }
}

func staticWrapperSignatureHasIncompleteTemplateIdentity(
    ctx: CjbindContext,
    signature: FunctionSig,
    visiting!: ItemSet = ItemSet()
): Bool {
    if (sourceTypeHasIncompleteTemplateIdentity(ctx, signature.returnType, visiting)) {
        return true
    }
    return signature.argumentTypes.any {
        argument => sourceTypeHasIncompleteTemplateIdentity(ctx, argument[1], visiting)
    }
}

func popDeclarator(stack: ArrayList<String>): String {
    let index = stack.size - 1
    let value = stack[index]
    stack.remove(at: index)
    return value
}

func drainDeclarator(stack: ArrayList<String>): String {
    let output = StringBuilder()
    while (!stack.isEmpty()) {
        output.append(popDeclarator(stack))
    }
    return output.toString()
}

func sourceItemName(ctx: CjbindContext, item: Item): String {
    let names = ArrayList<String>()
    let base = match (item.kind) {
        case ItemKind.KindType(ty) => ty.sourceName.getOrDefault({=> item.baseName(ctx)})
        case _ => item.baseName(ctx)
    }
    if (!base.isEmpty()) {
        names.add(base)
    }

    var parent = item.parentId
    while (parent != ctx.rootModule) {
        let ancestor = ctx.resolveItem(parent)
        match (ancestor.kind) {
            case ItemKind.KindModule(module) =>
                if (let Some(name) <- module.name && !name.isEmpty()) {
                    names.add(name)
                }
            case ItemKind.KindType(ty) =>
                let name = ty.sourceName.getOrDefault({=> ancestor.baseName(ctx)})
                if (!name.isEmpty()) {
                    names.add(name)
                }
            case _ => ()
        }
        parent = ancestor.parentId
    }
    names.reverse()
    return String.join(names.toArray(), delimiter: "::")
}

func sourceNamespaces(ctx: CjbindContext, item: Item): Array<String> {
    let names = ArrayList<String>()
    var parent = item.parentId
    while (parent != ctx.rootModule) {
        let ancestor = ctx.resolveItem(parent)
        if (let ItemKind.KindModule(module) <- ancestor.kind) {
            if (let Some(name) <- module.name && !name.isEmpty()) {
                names.add(name)
            }
        }
        parent = ancestor.parentId
    }
    names.reverse()
    return names.toArray()
}

func intSourceName(kind: TypeKindIntKind, isCxx: Bool): String {
    return match (kind) {
        case TypeKindIntKind.IntKindBool => if (isCxx) { "bool" } else { "_Bool" }
        case TypeKindIntKind.IntKindSChar | TypeKindIntKind.IntKindI8 => "signed char"
        case TypeKindIntKind.IntKindUChar | TypeKindIntKind.IntKindU8 => "unsigned char"
        case TypeKindIntKind.IntKindWChar(_) => "wchar_t"
        case TypeKindIntKind.IntKindChar(_) => "char"
        case TypeKindIntKind.IntKindChar16 => "char16_t"
        case TypeKindIntKind.IntKindShort | TypeKindIntKind.IntKindI16 => "short"
        case TypeKindIntKind.IntKindUShort | TypeKindIntKind.IntKindU16 => "unsigned short"
        case TypeKindIntKind.IntKindInt | TypeKindIntKind.IntKindI32 => "int"
        case TypeKindIntKind.IntKindUInt | TypeKindIntKind.IntKindU32 => "unsigned int"
        case TypeKindIntKind.IntKindLong => "long"
        case TypeKindIntKind.IntKindULong => "unsigned long"
        case TypeKindIntKind.IntKindLongLong | TypeKindIntKind.IntKindI64 => "long long"
        case TypeKindIntKind.IntKindULongLong | TypeKindIntKind.IntKindU64 => "unsigned long long"
        case TypeKindIntKind.IntKindI128 => "__int128"
        case TypeKindIntKind.IntKindU128 => "unsigned __int128"
        case TypeKindIntKind.IntKindCustom(value) => value.name
    }
}

func floatSourceName(kind: TypeKindFloatKind): String {
    return match (kind) {
        case TypeKindFloatKind.FloatKindFloat16 => "_Float16"
        case TypeKindFloatKind.FloatKindFloat => "float"
        case TypeKindFloatKind.FloatKindDouble => "double"
        case TypeKindFloatKind.FloatKindLongDouble => "long double"
        case TypeKindFloatKind.FloatKindFloat128 => "__float128"
    }
}

/// Spell the calling convention on a nested function declarator. The outer
/// bridge itself intentionally keeps the platform C ABI; this annotation is
/// only for function pointer parameters/returns whose pointee ABI must not be
/// silently changed while reconstructing the source declaration.
func sourceCallingConvention(abi: ClangAbi): String {
    return match (abi) {
        case ClangAbi.Known(Abi.C) => ""
        case ClangAbi.Known(Abi.Stdcall) => "__attribute__((stdcall))"
        case ClangAbi.Known(Abi.Fastcall) => "__attribute__((fastcall))"
        case ClangAbi.Known(Abi.ThisCall) => "__attribute__((thiscall))"
        case ClangAbi.Known(Abi.Vectorcall) => "__attribute__((vectorcall))"
        case ClangAbi.Known(Abi.Aapcs) => "__attribute__((pcs(\"aapcs\")))"
        case ClangAbi.Known(Abi.Win64) => "__attribute__((ms_abi))"
        case ClangAbi.Unknown(value) =>
            throw Exception("calling convention '${value}' cannot be serialized in a static wrapper")
    }
}

func serializeNonTypeTemplateArgument(argument: NonTypeTemplateArgument): String {
    if (argument.isBoolean) {
        return if (argument.unsignedValue == 0) { "false" } else { "true" }
    }
    let literal = if (argument.isUnsigned) {
        "${argument.unsignedValue}ULL"
    } else {
        let value = argument.signedValue.toString()
        if (value == "-9223372036854775808") {
            // Writing INT64_MIN as a single decimal token first creates an
            // unsigned literal. Spell it as a constant expression instead so
            // it remains a valid signed non-type template argument.
            "(-9223372036854775807LL - 1LL)"
        } else {
            "${value}LL"
        }
    }
    if (let Some(enumType) <- argument.enumTypeSpelling) {
        let qualified = if (enumType.startsWith("::")) {
            enumType
        } else {
            "::${enumType}"
        }
        // An integer constant is not implicitly convertible to an enum
        // non-type template parameter in C++14. Reconstruct the typed value.
        return "static_cast<${qualified}>(${literal})"
    }
    return literal
}

func serializeTemplateArguments(
    ctx: CjbindContext,
    instantiation: TemplateInstantiation,
    isCxx: Bool
): String {
    let rendered = ArrayList<String>()
    var typeArgumentIndex = 0
    for (position in 0..instantiation.argumentCount()) {
        if (let Some(argument) <- instantiation.nonTypeArgumentAt(UInt32(position))) {
            rendered.add(serializeNonTypeTemplateArgument(argument))
            continue
        }
        if (typeArgumentIndex >= instantiation.arguments.size) {
            throw Exception("invalid C++ template argument positions")
        }
        rendered.add(serializeSourceType(
            ctx,
            instantiation.arguments[typeArgumentIndex],
            ArrayList<String>(),
            isCxx
        ))
        typeArgumentIndex += 1
    }
    if (typeArgumentIndex != instantiation.arguments.size) {
        throw Exception("invalid C++ template argument positions")
    }
    return String.join(rendered.toArray(), delimiter: ", ")
}

func serializeFunctionType(
    ctx: CjbindContext,
    signature: FunctionSig,
    stack: ArrayList<String>,
    isCxx: Bool
): String {
    let callingConvention = sourceCallingConvention(signature.abi)
    let innerDeclarator = drainDeclarator(stack)
    let declarator = if (callingConvention.isEmpty()) {
        "(" + innerDeclarator + ")"
    } else {
        "(" + callingConvention + " " + innerDeclarator + ")"
    }
    let arguments = ArrayList<String>()
    var unnamed = 0
    for ((name, typeId) in signature.argumentTypes) {
        let argumentName = match (name) {
            case Some(value) where !value.isEmpty() => value
            case _ =>
                unnamed += 1
                "arg_${unnamed}"
        }
        arguments.add(serializeSourceType(
            ctx,
            typeId,
            ArrayList<String>([argumentName]),
            isCxx
        ))
    }
    // Clang classifies both an ellipsis-only C++ prototype and an old-style
    // C `foo()` declaration as variadic.  The former must retain its ellipsis,
    // while the latter must stay a no-argument prototype.
    let isVariadic = if (isCxx) {
        signature.rawIsVariadic()
    } else {
        signature.getIsVariadic()
    }
    if (isVariadic) {
        arguments.add("...")
    } else if (arguments.isEmpty()) {
        arguments.add("void")
    }
    let functionDeclarator = "${declarator} (${String.join(arguments.toArray(), delimiter: ", ")})"
    // Thread the complete function declarator through the return type. This is
    // required for nested forms such as a callback returning a pointer to an
    // array: `int (*(*callback)(void))[4]`.
    return serializeSourceType(
        ctx,
        signature.returnType,
        ArrayList<String>([functionDeclarator]),
        isCxx
    )
}

// Serializes a C/C++ type using a declarator stack. Keeping the declarator
// separate is what makes nested forms such as `int (*callback)(int)` render
// correctly without relying on compiler-specific `typeof` extensions.
func serializeSourceType(
    ctx: CjbindContext,
    typeId: TypeId,
    stack: ArrayList<String>,
    isCxx: Bool
): String {
    // Cangjie-side template materializations have synthetic names which do
    // not exist in the source header. A C++ bridge must always spell the
    // original C++ type and its original template arguments.
    if (!isCxx) {
        if (let Some(replacement) <- ctx.codegenTemplateReplacement(typeId)) {
            if (replacement != typeId) {
                return serializeSourceType(ctx, replacement, stack, isCxx)
            }
        }
    }

    let item = ctx.resolveItem(typeId)
    let ty = item.kind.expectType()
    let qualifier = if (ty.isConst) { "const " } else { "" }
    var output = match (ty.kind) {
        case TypeKind.TypeKindVoid => qualifier + "void"
        case TypeKind.TypeKindNullPtr =>
            if (!isCxx) {
                throw Exception("nullptr_t cannot be serialized in C mode")
            }
            qualifier + "decltype(nullptr)"
        case TypeKind.TypeKindInt(kind) => qualifier + intSourceName(kind, isCxx)
        case TypeKind.TypeKindFloat(kind) => qualifier + floatSourceName(kind)
        case TypeKind.TypeKindComplex(kind) => qualifier + floatSourceName(kind) + " _Complex"
        case TypeKind.TypeKindAlias(inner) =>
            // Keep named source aliases. Expanding `typedef struct { ... } T`
            // would invent a tag that never existed, and expanding callback
            // aliases can also discard declarator attributes such as a calling
            // convention. Anonymous/synthetic aliases still fall back to the
            // underlying type.
            if (ty.sourceName.isSome()) {
                qualifier + sourceItemName(ctx, item)
            } else {
                return serializeSourceType(ctx, inner, stack, isCxx)
            }
        case TypeKind.TypeKindTemplateAlias(inner, _) =>
            return serializeSourceType(ctx, inner, stack, isCxx)
        case TypeKind.TypeKindArray(inner, length) =>
            let current = drainDeclarator(stack)
            // Postfix array binding is tighter than a pointer/reference prefix.
            // Parenthesize the accumulated prefix for `T (*name)[N]`, while an
            // ordinary array and an array of pointers remain `T name[N]` and
            // `T *name[N]`, respectively.
            let arrayBase = if (current.startsWith("*") || current.startsWith("&")) {
                "(${current})"
            } else {
                current
            }
            return serializeSourceType(
                ctx,
                inner,
                ArrayList<String>(["${arrayBase}[${length}]"]),
                isCxx
            )
        case TypeKind.TypeKindFunction(signature) =>
            return serializeFunctionType(ctx, signature, stack, isCxx)
        case TypeKind.TypeKindPointer(inner) =>
            stack.add(if (ty.isConst) { "* const " } else { "*" })
            return serializeSourceType(ctx, inner, stack, isCxx)
        case TypeKind.TypeKindReference(inner) =>
            if (!isCxx) {
                throw Exception("C++ reference encountered in C mode")
            }
            stack.add("&")
            return serializeSourceType(ctx, inner, stack, isCxx)
        case TypeKind.TypeKindComp(comp) =>
            let tag = if (isCxx) {
                ""
            } else if (comp.isUnion()) {
                "union "
            } else {
                "struct "
            }
            qualifier + tag + sourceItemName(ctx, item)
        case TypeKind.TypeKindEnum(_) =>
            qualifier + (if (isCxx) { "" } else { "enum " }) + sourceItemName(ctx, item)
        case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
            if (!isCxx) {
                throw Exception("C++ template instantiation encountered in C mode")
            }
            if (!instantiation.argumentsComplete) {
                throw Exception(
                    "incomplete C++ template argument identity encountered in a static wrapper"
                )
            }
            let definition = instantiation.definition
                .intoResolver()
                .throughTypeRefs()
                .resolve(ctx)
            qualifier + sourceItemName(ctx, definition) +
                "<" + serializeTemplateArguments(ctx, instantiation, true) + ">"
        case TypeKind.ResolvedTypeRef(inner) =>
            let rendered = serializeSourceType(ctx, inner, stack, isCxx)
            return if (ty.isConst && !rendered.startsWith("const ")) {
                "const " + rendered
            } else {
                rendered
            }
        case TypeKind.TypeKindObjCId => qualifier + "id"
        case TypeKind.TypeKindObjCSel => qualifier + "SEL"
        case TypeKind.TypeKindObjCInterface(iface) => qualifier + iface.name
        case TypeKind.TypeKindObjCBlockPointer(_) =>
            throw Exception("Objective-C block pointers cannot be serialized as static wrappers")
        case TypeKind.TypeKindVector(_, _) =>
            throw Exception("vector types cannot be serialized as static wrappers")
        case TypeKind.TypeKindOpaque =>
            throw Exception("opaque types cannot be serialized as static wrappers")
        case TypeKind.TypeKindTypeParam =>
            throw Exception("template parameters cannot be serialized as static wrappers")
        case TypeKind.UnresolvedTypeRef(_, _, _) =>
            throw Exception("unresolved types cannot be serialized as static wrappers")
    }

    if (!stack.isEmpty()) {
        output += " " + drainDeclarator(stack)
    }
    return output
}

func isVoidReturn(ctx: CjbindContext, typeId: TypeId): Bool {
    return match (ctx.resolveType(typeId).canonicalType(ctx).kind) {
        case TypeKind.TypeKindVoid => true
        case _ => false
    }
}

func serializeStaticWrapper(
    ctx: CjbindContext,
    wrapper: StaticWrapper,
    isCxx: Bool
): String {
    let item = ctx.resolveItem(wrapper.itemId)
    let function = item.kind.expectFunction()
    let signature = match (ctx.resolveType(function.signature).canonicalType(ctx).kind) {
        case TypeKind.TypeKindFunction(value) => value
        case _ => throw Exception("static wrapper signature was not a function type")
    }

    let declarations = ArrayList<String>()
    let callArguments = ArrayList<String>()
    var unnamed = 0
    for ((name, typeId) in signature.argumentTypes) {
        let argumentName = match (name) {
            case Some(value) where !value.isEmpty() => value
            case _ =>
                unnamed += 1
                "arg_${unnamed}"
        }
        declarations.add(serializeSourceType(
            ctx,
            typeId,
            ArrayList<String>([argumentName]),
            isCxx
        ))
        callArguments.add(argumentName)
    }
    if (declarations.isEmpty()) {
        declarations.add("void")
    }

    let functionDeclarator = wrapper.symbolName + "(" +
        String.join(declarations.toArray(), delimiter: ", ") + ")"
    let declaration = serializeSourceType(
        ctx,
        signature.returnType,
        ArrayList<String>([functionDeclarator]),
        isCxx
    )
    let returnPrefix = if (isVoidReturn(ctx, signature.returnType)) { "" } else { "return " }
    let body = "${declaration} { ${returnPrefix}${function.sourceName}(" +
        String.join(callArguments.toArray(), delimiter: ", ") + "); }"

    if (!isCxx) {
        return body
    }

    let output = StringBuilder()
    let namespaces = sourceNamespaces(ctx, item)
    for (namespace in namespaces) {
        output.append("namespace ${namespace} {\n")
    }
    output.append("extern \"C\" ${body}\n")
    var remaining = namespaces.size
    while (remaining > 0) {
        output.append("}\n")
        remaining -= 1
    }
    return output.toString().trimEnd()
}

func wrapperSourcePath(ctx: CjbindContext, isCxx: Bool): Path {
    let base = match (ctx.options.wrapStaticFnsPath) {
        case Some(value) => Path(value)
        case None => getTempDirectory().join("cjbind").join("extern")
    }
    let stem = if (base.extensionName.isEmpty()) {
        base.fileName
    } else {
        base.fileNameWithoutExtension
    }
    let extension = if (isCxx) { "cpp" } else { "c" }
    let fileName = "${stem}.${extension}"
    return if (base.parent.isEmpty()) { Path(fileName) } else { base.parent.join(fileName) }
}

func includePath(header: String): String {
    var path = Path(header)
    try {
        path = canonicalize(path)
    } catch (_: Exception) {
        // Preserve virtual/non-filesystem inputs so the compiler can still
        // resolve them through the caller's include flags.
    }
    return path.toString().replace("\\", "/").replace("\"", "\\\"")
}

public func serializeStaticWrappers(
    ctx: CjbindContext,
    wrappers: ArrayList<StaticWrapper>
): Result<Unit, CodegenError> {
    if (wrappers.isEmpty()) {
        return Ok<Unit, CodegenError>(())
    }

    let isCxx = usesCxxLanguage(ctx.options)
    let code = StringBuilder()
    for (header in ctx.options.headers) {
        code.append("#include \"${includePath(header)}\"\n")
    }
    code.append("\n// Static wrappers\n\n")

    for (wrapper in wrappers) {
        let item = ctx.resolveItem(wrapper.itemId)
        try {
            code.append(serializeStaticWrapper(ctx, wrapper, isCxx))
            code.append("\n")
        } catch (error: Exception) {
            return Err<Unit, CodegenError>(CodegenError.Serialize(CodegenSerializeError(
                error.message,
                item.canonicalName(ctx)
            )))
        }
    }

    let path = wrapperSourcePath(ctx, isCxx)
    try {
        if (!path.parent.isEmpty() && !exists(path.parent)) {
            Directory.create(path.parent, recursive: true)
        }
        File.writeTo(path, code.toString().toArray())
    } catch (error: Exception) {
        return Err<Unit, CodegenError>(CodegenError.Io(error.message))
    }
    return Ok<Unit, CodegenError>(())
}
