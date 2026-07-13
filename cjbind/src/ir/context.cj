package cjbind.ir

import cjbind_token.*
import std.collection.*
import std.fs.Path
import std.env.getTempDirectory
import cjbind.result.Result
import cjbind.clang
import cjbind.options.CjbindOptions

public type ItemId = UIntNative

public type TypeId = ItemId

public type ModuleId = ItemId

public func usesCxxLanguage(options: CjbindOptions): Bool {
    var languageFollows = false
    var explicitLanguage: ?Bool = None
    for (arg in options.clangArgs) {
        if (languageFollows) {
            explicitLanguage = if (arg == "none") { None } else { Some(arg.contains("c++")) }
            languageFollows = false
            continue
        }
        if (arg == "-x") {
            languageFollows = true
        } else if (arg.startsWith("-x") && arg.size > 2) {
            let language = arg[2..]
            explicitLanguage = if (language == "none") { None } else { Some(language.contains("c++")) }
        }
    }
    if (let Some(cxx) <- explicitLanguage) {
        return cxx
    }
    for (header in options.headers) {
        if (header.endsWith(".hpp") || header.endsWith(".hxx") || header.endsWith(".hh") ||
            header.endsWith(".h++") || header.endsWith(".HPP") || header.endsWith(".HXX") ||
            header.endsWith(".HH") || header.endsWith(".H++") || header.endsWith(".H") ||
            header.endsWith(".cc") || header.endsWith(".cpp") || header.endsWith(".cxx") ||
            header.endsWith(".c++") || header.endsWith(".C")) {
            return true
        }
    }
    return false
}

extend ItemId <: IsOpaque<Unit> & Trace<Tracer, Unit> {
    public func isOpaque(ctx: CjbindContext, _: Unit): Bool {
        return ctx.resolveItem(this).isOpaque(ctx, ())
    }

    // cjlint-ignore -start !G.ITF.04
    public func trace(ctx: CjbindContext, tracer: Tracer, _: Unit): Unit {
        ctx.resolveItem(this).trace(ctx, tracer, ())
    }
    // cjlint-ignore -end

    public func ancestors(ctx: CjbindContext): ItemAncestorsIter {
        return ItemAncestorsIter(ctx, this)
    }
}

public enum TypeKey <: Hashable & Equatable<TypeKey> {
    Usr(String)
    | Declaration(clang.Cursor)

    public func hashCode(): Int64 {
        match (this) {
            case Usr(v) => v.hashCode()
            case Declaration(v) => v.hashCode()
        }
    }

    public operator func ==(that: TypeKey): Bool {
        match ((this, that)) {
            case (Usr(v1), Usr(v2)) => v1 == v2
            case (Declaration(v1), Declaration(v2)) => v1 == v2
            case _ => false
        }
    }
}

func templateInstantiationName(spelling: String): String {
    var name = spelling
        .replace("::", "_")
        .replace("&&", "_rref")
        .replace("&", "_ref")
        .replace("const ", "const_")
        .replace("volatile ", "volatile_")
        .replace("<", "_open0_")
        .replace(">", "_close0")
        .replace("*", "_ptr")
        .replace("[", "_array_")
        .replace("]", "_endarray_")
        .replace("(", "_lparen_")
        .replace(")", "_rparen_")
        .replace("-", "_minus_")
        .replace("+", "_plus_")
        .replace("/", "_slash_")
        .replace("=", "_equals_")
        .replace("!", "_not_")
        .replace("%", "_percent_")
        .replace("^", "_xor_")
        .replace("|", "_or_")
        .replace("{", "_lbrace_")
        .replace("}", "_rbrace_")
        .replace("'", "_quote_")
        .replace("?", "_question_")
        .replace("~", "_tilde_")
        .replace(".", "_dot_")
        .replace(",", "_")
        .replace(" ", "_")
        .replace(":", "_")

    while (name.contains("__")) {
        name = name.replace("__", "_")
    }
    let safeName = StringBuilder()
    for (rune in name.toRuneArray()) {
        if (rune.isAsciiNumberOrLetter() || rune == r'_') {
            safeName.append("${rune}")
        } else {
            safeName.append("_u${UInt32(rune)}_")
        }
    }
    var result = safeName.toString().trimAscii()
    if (!result.isEmpty() && result.toRuneArray()[0].isAsciiNumber()) {
        result = "template_${result}"
    }
    return if (result.isEmpty()) { "template_instantiation" } else { result }
}

public class PartialType <: Equatable<PartialType> {
    public let decl: clang.Cursor
    public let id: ItemId

    init(decl: clang.Cursor, id: ItemId) {
        this.decl = decl
        this.id = id
    }

    public operator func ==(that: PartialType): Bool {
        return decl == that.decl && id == that.id
    }
}

public class CjbindContext <: Resource {
    var _released: Bool = false
    public let options: CjbindOptions

    public let items: ArrayList<?Item>
    public let types: HashMap<TypeKey, TypeId> = HashMap()
    public let typeDeclarations: HashMap<clang.Cursor, TypeId> = HashMap()
    public let modules: HashMap<clang.Cursor, ModuleId> = HashMap()
    public let typeParams: HashMap<clang.Cursor, TypeId> = HashMap()
    public let templateInstantiations: HashMap<String, TypeId> = HashMap()

    public let rootModule: ModuleId
    public var currentModule: ModuleId

    public let semanticParents: HashMap<clang.Cursor, ItemId> = HashMap()

    public let currentlyParsedTypes: ArrayList<PartialType> = ArrayList()

    public let parsedMacros: HashMap<String, MacroEvalResult> = HashMap()

    public var objcInterfaces: HashMap<String, ItemId> = HashMap<String, ItemId>()

    public let includes: HashMap<String, (String, UIntNative)> = HashMap()
    public let deps: HashSet<String>

    public var collectedTyperefs: Bool = false
    public var inCodegen: Bool = false

    public let index: clang.Index
    public let translationUnit: clang.TranslationUnit
    public var fallbackTu: Option<clang.FallbackTranslationUnit> = None
    public let targetInfo: clang.TargetInfo

    public var codegenItems: Option<ItemSet> = None

    public var needBitfieldAllocation: ArrayList<ItemId> = ArrayList()

    public var enumTypedefCombos: ?HashSet<ItemId> = None

    public init(options: CjbindOptions) {
        this.options = options

        this.index = clang.Index(false, true)

        this.translationUnit = clang.TranslationUnit(
            this.index,
            "",
            options.clangArgs.toArray(),
            clang.CXTranslationUnit_Flags_CXTranslationUnit_DetailedPreprocessingRecord
        )

        this.targetInfo = clang.TargetInfo(translationUnit)
        let rootModuleItem = Item(
            0,
            None,
            0,
            KindModule(Module("root")),
            None
        )

        this.items = ArrayList<?Item>([rootModuleItem])
        this.deps = HashSet(options.headers)
        this.rootModule = 0
        this.currentModule = 0
    }

    public func isClosed(): Bool { _released }

    public func close(): Unit {
        if (!_released) {
            _released = true
            if (let Some(ftu) <- this.fallbackTu) {
                ftu.close()
            }
            this.translationUnit.close()
            this.index.close()
        }
    }


    // cjlint-ignore -start !G.FUN.01
    public func tryEnsureFallbackTranslationUnit(
    ): Option<clang.FallbackTranslationUnit> {
        if (this.fallbackTu.isSome()) {
            return this.fallbackTu
        }

        let tmpDir = getTempDirectory().toString()
        let cxxMode = usesCxxLanguage(this.options)
        let file = if (cxxMode) { "${tmpDir}/.macro_eval.cpp" } else { "${tmpDir}/.macro_eval.c" }

        let index = clang.Index(false, false)

        let headerNamesToCompile = ArrayList<String>()
        let headerPaths = ArrayList<String>()
        let headerIncludes = ArrayList<String>()
        let singleHeader = if (let Some(h) <- this.options.headers.last) {
            h
        } else {
            return None
        }

        let headerCnt = this.options.headers.size
        for (i in 0..(headerCnt - 1)) {
            let header = this.options.headers[i]
            let path = Path(header)
            if (path.parent.isEmpty()) {
                headerPaths.add(".")
            } else {
                headerPaths.add(path.parent.toString())
            }
            let headerName = path.fileName
            headerIncludes.add(headerName)
            let compileName = if (let Some(v) <- headerName.split(".h", removeEmpty: true).first) {
                v
            } else {
                return None
            }

            headerNamesToCompile.add(compileName)
        }
        let pchSuffix = if (cxxMode) { "-precompile.hpp.pch" } else { "-precompile.h.pch" }
        let pchName = String.join(headerNamesToCompile.toArray(), delimiter: "-") + pchSuffix
        let pch = "${tmpDir}/${pchName}"

        var cArgs = ArrayList<String>()
        let targetArg = "--target=${this.targetInfo.triple}"
        cArgs.add(targetArg)
        cArgs.add("-x")
        cArgs.add(if (cxxMode) { "c++-header" } else { "c-header" })
        for (h in headerPaths) {
            cArgs.add("-I${h}")
        }
        for (h in headerIncludes) {
            cArgs.add("-include")
            cArgs.add(h)
        }
        let tu = clang.TranslationUnit(
            index,
            singleHeader,
            cArgs.toArray(),
            clang.CXTranslationUnit_Flags_CXTranslationUnit_ForSerialization
        )
        let saveResult = tu.save(pch)
        tu.close()
        index.close()
        if (let None <- saveResult.ok()) {
            return None
        }

        cArgs = ArrayList<String>()
        cArgs.add(targetArg)
        cArgs.add("-include-pch")
        cArgs.add(pch)

        this.fallbackTu = Some(
            clang.FallbackTranslationUnit(
                file,
                pch,
                cArgs.toArray()
            )
        )

        return this.fallbackTu
    }
    // cjlint-ignore -end

    public func parsedMacro(macro_name: String): Bool {
        return this.parsedMacros.contains(macro_name)
    }

    public func noteParsedMacro(id: String, value: MacroEvalResult): Unit {
        this.parsedMacros.add(id, value)
    }

    public func withModule(module_id: ModuleId, cb: (CjbindContext) -> Unit): Unit {
        let prev_module = this.currentModule
        this.currentModule = module_id

        cb(this)

        this.currentModule = prev_module
    }

    public func module(cursor: clang.Cursor): ModuleId {
        let canonicalCursor = cursor.canonical()
        if (let Some(id) <- this.modules.get(canonicalCursor)) {
            return id
        }

        let spelling = canonicalCursor.spelling()
        let name: ?String = if (spelling.isEmpty()) {
            None
        } else {
            Some(spelling)
        }
        let kind = if (canonicalCursor.isInlineNamespace()) {
            ModuleKind.Inline
        } else {
            ModuleKind.Normal
        }
        let id = this.nextItemId()
        let item = Item(
            id,
            None,
            this.currentModule,
            ItemKind.KindModule(Module(name, kind: kind)),
            Some(canonicalCursor.location())
        )
        this.modules.add(canonicalCursor, id)
        this.addItem(item, None, Some(canonicalCursor))
        return id
    }

    public func nextItemId(): ItemId {
        let ret = UIntNative(this.items.size)
        this.items.add(None)
        return ret
    }

    public func addItem(
        item: Item,
        declaration: ?clang.Cursor,
        _: ?clang.Cursor
    ): Unit {
        let id = item.id
        let isType = item.kind.isType()
        let isUnnamed = item.kind.isType() && item.kind.expectType().name.isNone()

        if (this.items[Int64(id)].isSome()) {
            throw Exception("Item with id ${id} already exists, WTF case")
        }

        if (item.id != this.rootModule) {
            this.addItemToModule(item)
        }

        if (isType && item.kind.expectType().isComp()) {
            this.needBitfieldAllocation.add(id)
        }

        this.items[Int64(id)] = item

        if (!isType) {
            return
        }

        if (let Some(decl) <- declaration) {
            this.typeDeclarations.add(decl, id)
            let candecl = decl.canonical()
            if (!candecl.isValid()) {
                return
            }

            let key = if (isUnnamed) {
                TypeKey.Declaration(candecl)
            } else if (let Some(usr) <- candecl.usr()) {
                TypeKey.Usr(usr)
            } else {
                TypeKey.Declaration(candecl)
            }

            this.types.add(key, id)
        }
    }

    public func addItemToModule(item: Item): Unit {
        let p = this.items[Int64(item.parentId)]
        if (let Some(pp) <- p) {
            if (let Some(module) <- pp.asModule()) {
                module.children.add(item.id)
                return
            }
        }

        this.items[Int64(this.currentModule)].getOrThrow().asModule().getOrThrow().children.add(item.id)
        return
    }

    public func getResolvedType(decl: clang.CanonicalTypeDeclaration): ?TypeId {
        let ret1 = this.types.get(TypeKey.Declaration(decl.cursor))

        if (let Some(ret) <- ret1) {
            return ret
        }

        let usr = decl.cursor.usr()

        if (let Some(u) <- usr) {
            return this.types.get(TypeKey.Usr(u))
        }

        return None
    }

    public func addBuiltinItem(item: Item): Unit {
        this.addItemToModule(item)
        let id = item.id

        if (items[Int64(id)].isSome()) {
            throw Exception("Inserted type twice?")
        }

        items[Int64(id)] = item
    }

    public func buildWrapper(
        withId: ItemId,
        wrapperId: TypeId,
        parentId: ?ItemId,
        ty: clang.Type,
        isConst: Bool
    ): TypeId {
        let spelling = ty.spelling()
        let layout = ty.fallibleLayout(this).ok()
        let location = ty.declaration().location()
        let typeKind = TypeKind.ResolvedTypeRef(wrapperId)
        let ity = Type(Some(spelling), layout, typeKind, isConst)
        let item = Item(
            withId,
            None,
            parentId.getOrDefault() {=> this.currentModule},
            ItemKind.KindType(ity),
            Some(location)
        )
        this.addBuiltinItem(item)

        return withId
    }

    public func buildTyWrapper(
        withId: ItemId,
        wrapperId: TypeId,
        parentId: ?ItemId,
        ty: clang.Type
    ): TypeId {
        return this.buildWrapper(withId, wrapperId, parentId, ty, ty.isConst())
    }

    // cjlint-ignore -start !G.FUN.01
    public func buildBuiltinTy(ty: clang.Type): ?TypeId {
        let typeKindDef: ?TypeKind = {
            =>
            let k = ty.kind()

            if (k == clang.CXTypeKind_CXType_NullPtr) {
                return TypeKind.TypeKindNullPtr
            }
            if (k == clang.CXTypeKind_CXType_Void) {
                return TypeKind.TypeKindVoid
            }
            if (k == clang.CXTypeKind_CXType_Bool) {
                return TypeKind.TypeKindInt(IntKindBool)
            }
            if (k == clang.CXTypeKind_CXType_Int) {
                return TypeKind.TypeKindInt(IntKindInt)
            }
            if (k == clang.CXTypeKind_CXType_UInt) {
                return TypeKind.TypeKindInt(IntKindUInt)
            }
            if (k == clang.CXTypeKind_CXType_Char_S) {
                return TypeKind.TypeKindInt(IntKindChar(true))
            }
            if (k == clang.CXTypeKind_CXType_Char_U) {
                return TypeKind.TypeKindInt(IntKindChar(false))
            }
            if (k == clang.CXTypeKind_CXType_SChar) {
                return TypeKind.TypeKindInt(IntKindSChar)
            }
            if (k == clang.CXTypeKind_CXType_UChar) {
                return TypeKind.TypeKindInt(IntKindUChar)
            }
            if (k == clang.CXTypeKind_CXType_Short) {
                return TypeKind.TypeKindInt(IntKindShort)
            }
            if (k == clang.CXTypeKind_CXType_UShort) {
                return TypeKind.TypeKindInt(IntKindUShort)
            }
            if (k == clang.CXTypeKind_CXType_WChar) {
                // TODO: determine wchar_t signedness from target info
                return TypeKind.TypeKindInt(IntKindWChar(false))
            }
            if (k == clang.CXTypeKind_CXType_Char16) {
                if (this.options.useDistinctChar16T) {
                    return TypeKind.TypeKindInt(IntKindChar16)
                }
                return TypeKind.TypeKindInt(IntKindU16)
            }
            if (k == clang.CXTypeKind_CXType_Char32) {
                return TypeKind.TypeKindInt(IntKindU32)
            }
            if (k == clang.CXTypeKind_CXType_Long) {
                return TypeKind.TypeKindInt(IntKindLong)
            }
            if (k == clang.CXTypeKind_CXType_ULong) {
                return TypeKind.TypeKindInt(IntKindULong)
            }
            if (k == clang.CXTypeKind_CXType_LongLong) {
                return TypeKind.TypeKindInt(IntKindLongLong)
            }
            if (k == clang.CXTypeKind_CXType_ULongLong) {
                return TypeKind.TypeKindInt(IntKindULongLong)
            }
            if (k == clang.CXTypeKind_CXType_Int128) {
                return TypeKind.TypeKindInt(IntKindI128)
            }
            if (k == clang.CXTypeKind_CXType_UInt128) {
                return TypeKind.TypeKindInt(IntKindU128)
            }
            if (k == clang.CXTypeKind_CXType_Float16 || k == clang.CXTypeKind_CXType_Half) {
                return TypeKind.TypeKindFloat(FloatKindFloat16)
            }
            if (k == clang.CXTypeKind_CXType_Float) {
                return TypeKind.TypeKindFloat(FloatKindFloat)
            }
            if (k == clang.CXTypeKind_CXType_Double) {
                return TypeKind.TypeKindFloat(FloatKindDouble)
            }
            if (k == clang.CXTypeKind_CXType_LongDouble) {
                return TypeKind.TypeKindFloat(FloatKindLongDouble)
            }
            if (k == clang.CXTypeKind_CXType_Float128) {
                return TypeKind.TypeKindFloat(FloatKindFloat128)
            }
            if (k == clang.CXTypeKind_CXType_Complex) {
                let ft = ty.elemType().getOrThrow().kind()
                let floatKind = {
                    =>
                    if (ft == clang.CXTypeKind_CXType_Float16 || ft == clang.CXTypeKind_CXType_Half) {
                        return FloatKindFloat16
                    }
                    if (ft == clang.CXTypeKind_CXType_Float) {
                        return FloatKindFloat
                    }
                    if (ft == clang.CXTypeKind_CXType_Double) {
                        return FloatKindDouble
                    }
                    if (ft == clang.CXTypeKind_CXType_LongDouble) {
                        return FloatKindLongDouble
                    }
                    if (ft == clang.CXTypeKind_CXType_Float128) {
                        return FloatKindFloat128
                    }
                    throw Exception("unknown float type ${ft}")
                }()
                return TypeKind.TypeKindComplex(floatKind)
            }
            return None<TypeKind>
        }()
        let typeKind = typeKindDef ?? return None
        let spelling = ty.spelling()
        let isConst = ty.isConst()
        let layout = ty.fallibleLayout(this).ok()
        let location = ty.declaration().location()
        let ity = Type(Some(spelling), layout, typeKind, isConst)

        let nid = this.nextItemId()
        let item = Item(
            nid,
            None,
            this.rootModule,
            ItemKind.KindType(ity),
            Some(location)
        )

        this.addBuiltinItem(item)
        return nid
    }

    // cjlint-ignore -end

    public func builtinOrResolvedTy(
        withId: ItemId,
        parentId: ?ItemId,
        ty: clang.Type,
        location: ?clang.Cursor
    ): ?TypeId {
        let locationKind = location.map({cursor => cursor.kind()})
        let isTemplateDefinition = locationKind == Some(clang.CXCursorKind_CXCursor_ClassTemplate) ||
            locationKind == Some(clang.CXCursorKind_CXCursor_ClassTemplatePartialSpecialization) ||
            locationKind == Some(clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl)
        if (isTemplateDefinition) {
            return None
        }
        if (ty != ty.canonicalType() &&
            (ty.declaration().kind() == clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl ||
            (ty.kind() == clang.CXTypeKind_CXType_Typedef &&
            (ty.templateArgs().isSome() || ty.spelling().contains("<"))))) {
            return None
        }
        let isTemplateInstantiation = !isTemplateDefinition &&
            ty.kind() != clang.CXTypeKind_CXType_Typedef &&
            ty.templateArgs().map({args => !args.isEmpty()}).getOrDefault({=> false})
        if (isTemplateInstantiation) {
            if (let Some(instantiation) <- TemplateInstantiation.fromTy(ty, this)) {
                if (let Some(concrete) <- this.buildTemplateInstantiation(
                    withId,
                    instantiation,
                    parentId,
                    ty,
                    location
                )) {
                    return Some(concrete)
                }
            }
        }

        if (let Some(decl) <- ty.canonicalDeclaration(location)) {
            if (let Some(tid) <- this.getResolvedType(decl)) {
                return Some(this.buildTyWrapper(withId, tid, parentId, ty))
            }
        }

        return this.buildBuiltinTy(ty)
    }

    func buildTemplateInstantiation(
        withId: ItemId,
        instantiation: TemplateInstantiation,
        parentId: ?ItemId,
        ty: clang.Type,
        location: ?clang.Cursor
    ): ?TypeId {
        let keyParts = ArrayList<String>()
        let definitionId = instantiation.definition
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(this)
            .id
        keyParts.add(definitionId.toString())
        for (argument in instantiation.arguments) {
            let argumentType = this.resolveType(argument)
            let argumentId = argument
                .intoResolver()
                .throughTypeRefs()
                .throughTypeAliases()
                .resolve(this)
                .id
            keyParts.add("${argumentId}:${argumentType.isConst}")
        }
        if (let Some(identity) <- instantiation.nonTypeIdentity) {
            keyParts.add(identity)
        }
        let key = String.join(keyParts.toArray(), delimiter: ":")
        if (let Some(existing) <- this.templateInstantiations.get(key)) {
            return Some(this.buildTyWrapper(withId, existing, parentId, ty))
        }

        this.templateInstantiations.add(key, withId)
        let spelling = ty.spelling()
        let name = templateInstantiationName(spelling)
        let declaration = ty.declaration()
        let hasConcreteDefinition = declaration.isDefinition() && declaration.specialized().isSome()
        let templateType = Type(
            Some(name),
            ty.fallibleLayout(this).ok(),
            TypeKind.TypeKindTemplateInstantiation(instantiation),
            ty.isConst()
        )
        this.addItem(
            Item(
                withId,
                None,
                parentId ?? this.currentModule,
                ItemKind.KindType(templateType),
                location.map({cursor => cursor.location()})
            ),
            if (hasConcreteDefinition) { Some(declaration.canonical()) } else { None },
            location
        )

        if (hasConcreteDefinition) {
            if (let Ok(comp) <- CompInfo.fromTy(withId, ty, Some(declaration), this)) {
                let representsConcreteDefinition = comp.hasFields() || !comp.baseMembers.isEmpty() ||
                    ty.fallibleLayout(this).ok().map({layout => layout.size <= 1}).getOrDefault({=> false})
                if (representsConcreteDefinition) {
                    this.resolveItem(withId).kind = ItemKind.KindType(
                        Type(
                            Some(name),
                            ty.fallibleLayout(this).ok(),
                            TypeKind.TypeKindComp(comp),
                            ty.isConst()
                        )
                    )
                    this.needBitfieldAllocation.add(withId)
                }
            }
        }
        return Some(withId)
    }

    func instantiateTemplateType(
        sourceId: TypeId,
        substitutions: HashMap<TypeId, TypeId>,
        failed: Box<Bool>
    ): TypeId {
        if (let Some(substituted) <- substitutions.get(sourceId)) {
            return substituted
        }

        let resolvedSourceId = sourceId
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(this)
            .id
        for ((parameter, substituted) in substitutions) {
            let resolvedParameter = parameter
                .intoResolver()
                .throughTypeRefs()
                .throughTypeAliases()
                .resolve(this)
                .id
            if (resolvedParameter == resolvedSourceId) {
                return substituted
            }
        }

        let source = match (this.safeResolveType(sourceId)) {
            case Some(value) => value
            case None => return sourceId
        }

        let newKind: ?TypeKind = match (source.kind) {
            case TypeKind.TypeKindPointer(inner) =>
                TypeKind.TypeKindPointer(this.instantiateTemplateType(inner, substitutions, failed))
            case TypeKind.TypeKindReference(inner) =>
                TypeKind.TypeKindReference(this.instantiateTemplateType(inner, substitutions, failed))
            case TypeKind.TypeKindArray(inner, length) =>
                TypeKind.TypeKindArray(this.instantiateTemplateType(inner, substitutions, failed), length)
            case TypeKind.TypeKindVector(inner, length) =>
                TypeKind.TypeKindVector(this.instantiateTemplateType(inner, substitutions, failed), length)
            case TypeKind.TypeKindAlias(inner) =>
                TypeKind.TypeKindAlias(this.instantiateTemplateType(inner, substitutions, failed))
            case TypeKind.TypeKindFunction(signature) =>
                let arguments = ArrayList<(?String, TypeId)>()
                for ((name, argument) in signature.argumentTypes) {
                    arguments.add((name, this.instantiateTemplateType(argument, substitutions, failed)))
                }
                TypeKind.TypeKindFunction(FunctionSig(
                    signature.name,
                    this.instantiateTemplateType(signature.returnType, substitutions, failed),
                    arguments.toArray(),
                    signature.isVariadicFunction(),
                    signature.abi,
                    valueAbiUnsupported: signature.valueAbiUnsupported
                ))
            case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
                for (argument in instantiation.arguments) {
                    let concreteArgument = this.instantiateTemplateType(argument, substitutions, failed)
                    if (concreteArgument != argument) {
                        failed.value = true
                    }
                }
                return sourceId
            case TypeKind.TypeKindComp(comp) =>
                if (!comp.templateParams.isEmpty() || comp.hasTemplateTypeParams ||
                    comp.hasNonTypeTemplateParams) {
                    failed.value = true
                }
                return sourceId
            case TypeKind.ResolvedTypeRef(inner) =>
                return this.instantiateTemplateType(inner, substitutions, failed)
            case _ => return sourceId
        }

        let instantiatedKind = newKind.getOrThrow()
        let instantiatedLayout: ?Layout = match (instantiatedKind) {
            case TypeKind.TypeKindArray(inner, length) =>
                this.resolveType(inner).getLayout(this).map {
                    layout => Layout(layout.size * Int32(length), layout.align)
                }
            case TypeKind.TypeKindVector(inner, length) =>
                this.resolveType(inner).getLayout(this).map {
                    layout => Layout(layout.size * Int32(length), layout.align)
                }
            case _ => source.layout
        }
        let newId = this.nextItemId()
        this.addItem(
            Item(
                newId,
                None,
                this.rootModule,
                ItemKind.KindType(Type(source.name, instantiatedLayout, instantiatedKind, source.isConst)),
                None
            ),
            None,
            None
        )
        substitutions.add(sourceId, newId)
        return newId
    }

    func instantiateTemplateComp(instantiation: TemplateInstantiation): ?CompInfo {
        let definitionCursor = instantiation.definitionCursor
            .definition()
            .getOrDefault({=> instantiation.definitionCursor})
        let latestDefinition = this.typeDeclarations.get(definitionCursor).getOrDefault {
            => this.getResolvedType(
            clang.CanonicalTypeDeclaration(
                instantiation.definitionCursor.curType(),
                instantiation.definitionCursor
            )
            ).getOrDefault({=> instantiation.definition})
        }
        if (this.resolveItemFallible(latestDefinition).isNone()) {
            return None
        }
        let definitionItem = latestDefinition
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(this)
        let definitionType = match (definitionItem.kind.asType()) {
            case Some(value) => value
            case None => return None
        }
        let definitionComp = match (definitionType.kind) {
            case TypeKind.TypeKindComp(value) => value
            case _ => return None
        }
        if (definitionComp.templateParams.size > instantiation.arguments.size ||
            definitionComp.hasNonTypeTemplateParams) {
            return None
        }

        let substitutions = HashMap<TypeId, TypeId>()
        for ((index, parameter) in definitionComp.templateParams.iterator().enumerate()) {
            substitutions.add(parameter, instantiation.arguments[index])
        }

        let rawFields = match (definitionComp.fields) {
            case CompFields.CompFieldsBefore(value) => value
            case _ => return None
        }
        let concreteFields = ArrayList<RawField>()
        let failedSubstitution = Box(false)
        for (field in rawFields) {
            concreteFields.add(
                RawField(
                    field.name,
                    this.instantiateTemplateType(field.ty, substitutions, failedSubstitution),
                    field.comment,
                    field.bitfieldWidth,
                    field.offset,
                    isPublic: field.isPublic
                )
            )
        }
        if (failedSubstitution.value) {
            return None
        }

        let concrete = CompInfo(definitionComp.kind, isCxxRecord: definitionComp.isCxxRecord)
        concrete.fields = CompFields.CompFieldsBefore(concreteFields)
        concrete.isForwardDeclaration = definitionComp.isForwardDeclaration
        concrete.packedAttr = definitionComp.packedAttr
        concrete.hasUnevaluableBitFieldWidth = definitionComp.hasUnevaluableBitFieldWidth
        concrete.foundUnknownAttr = definitionComp.foundUnknownAttr
        concrete.hasOwnVirtualMethod = definitionComp.hasOwnVirtualMethod
        concrete.hasDestructor = definitionComp.hasDestructor
        concrete.hasUnrepresentedVirtualMethod = definitionComp.hasUnrepresentedVirtualMethod

        for (base in definitionComp.baseMembers) {
            concrete.baseMembers.add(
                Base(
                    this.instantiateTemplateType(base.ty, substitutions, failedSubstitution),
                    base.kind,
                    base.fieldName,
                    base.isPublic
                )
            )
        }
        if (failedSubstitution.value) {
            return None
        }
        return Some(concrete)
    }

    func populateTemplateInstantiations(): Unit {
        let ids = ArrayList<TypeId>()
        for ((_, id) in this.templateInstantiations) {
            ids.add(id)
        }

        for (id in ids) {
            let item = match (this.resolveItemFallible(id)) {
                case Some(value) => value
                case None => continue
            }
            let ty = match (item.kind.asType()) {
                case Some(value) => value
                case None => continue
            }
            let instantiation = match (ty.kind) {
                case TypeKind.TypeKindTemplateInstantiation(value) => value
                case _ => continue
            }
            if (let Some(comp) <- this.instantiateTemplateComp(instantiation)) {
                item.kind = ItemKind.KindType(Type(ty.name, ty.layout, TypeKind.TypeKindComp(comp), ty.isConst))
                this.needBitfieldAllocation.add(id)
            } else {
                item.kind = ItemKind.KindType(Type(ty.name, ty.layout, TypeKind.TypeKindOpaque, ty.isConst))
            }
        }
    }

    public func beginParsing(partialTy: PartialType): Unit {
        this.currentlyParsedTypes.add(partialTy)
    }

    public func finishParsing(): PartialType {
        let ret = this.currentlyParsedTypes.last
        this.currentlyParsedTypes.remove(at: this.currentlyParsedTypes.size - 1)
        match (ret) {
            case Some(v) => return v
            case None => throw Exception("finish parsing without begin")
        }
    }

    public func resolveItemFallible(id: ItemId): ?Item {
        match (this.items.get(Int64(id))) {
            case Some(v) => v
            case None => None
        }
    }

    public func resolveItem(itemId: ItemId): Item {
        this.resolveItemFallible(itemId).getOrThrow()
    }

    public func resolveType(typeId: TypeId): Type {
        this.resolveItem(typeId).kind.expectType()
    }

    public func safeResolveType(typeId: TypeId): ?Type {
        this.resolveItemFallible(typeId).flatMap {
            t => t.kind.asType()
        }
    }

    public func addSemanticParent(
        def: clang.Cursor,
        parentId: ItemId
    ): Unit {
        this.semanticParents.add(def, parentId)
    }

    public func knownSemanticParent(def: clang.Cursor): ?ItemId {
        return this.semanticParents.get(def)
    }

    public func addDep(dep: String): Unit {
        this.deps.add(dep)
    }

    public func getItems(): Iterator<(ItemId, Item)> {
        this
            .items
            .iterator()
            .enumerate()
            .filterMap {
                v =>
                let idx = v[0]
                let it = v[1]
                let ret: Option<(ItemId, Item)> = match (it) {
                    case Some(v) => (UIntNative(idx), v)
                    case None => None
                }
                ret
            }
    }

    public func cjMangle(name: String): String {
        let builtins: Array<String> = ["acquireArrayRawData", "alignOf", "eprint", "eprintln", "ifNone", "ifSome", "max",
            "min", "print", "println", "refEq", "releaseArrayRawData", "sizeOf", "sleep", "zeroValue", "Byte", "Int",
            "UInt", "Int8", "Int16", "Int32", "Int64", "IntNative", "UInt8", "UInt16", "UInt32", "UInt64", "UIntNative",
            "Float16", "Float32", "Float64", "Bool", "Rune", "Unit", "CPointer", "CString", "Any", "Hasher",
            "ThreadContext", "Countable", "Collection", "Less", "Greater", "LessOrEqual", "GreaterOrEqual", "Comparable",
            "Equal", "NotEqual", "Equatable", "Hashable", "Iterable", "Resource", "ToString", "CType", "ArrayIterator",
            "Box", "Future", "Iterator", "Object", "RangeIterator", "StackTraceElement", "StringBuilder", "Thread",
            "ThreadLocal", "AnnotationKind", "Endian", "Ordering", "Option", "Array", "CPointerHandle",
            "CPointerResource", "CStringResource", "DefaultHasher", "Duration", "LibC", "Range", "String",
            "ArithmeticException", "Error", "Exception", "IllegalArgumentException", "IllegalFormatException",
            "IllegalMemoryException", "IllegalStateException", "IndexOutOfBoundsException", "NegativeArraySizeException",
            "NoneValueException", "OutOfMemoryError", "OverflowException", "SpawnException", "StackOverflowError",
            "TimeoutException", "UnsupportedException", "as", "break", "case", "catch", "class", "const", "continue",
            "do", "else", "enum", "extend", "for", "from", "func", "false", "finally", "foreign", "if", "in", "is",
            "init", "inout", "import", "interface", "let", "mut", "main", "macro", "match", "Nothing", "operator",
            "prop", "package", "quote", "return", "spawn", "super", "static", "struct", "synchronized", "try", "this",
            "true", "type", "throw", "This", "unsafe", "var", "VArray", "where", "while", "abstract", "open", "override",
            "private", "protected", "public", "redef", "get", "set", "sealed", "internal", "_", "Some", "None", "Init",
            "MemberFunction", "MemberProperty", "MemberVariable", "Parameter", "Type", "Big", "Little", "LT", "GT", "EQ"]

        let keyword = builtins.contains(name)

        if (name.contains("@") || name.contains("?") || name.contains("$") || keyword) {
            return name.replace("@", "_").replace("?", "_").replace("$", "_") + "_"
        }

        return name
    }

    public func cjIdent(name: String): String {
        return this.cjIdentRaw(this.cjMangle(name))
    }

    public func cjIdentRaw(name: String): String {
        return name
    }

    public func pointerWidth(): Int32 {
        return this.targetInfo.pointerWidth / 8
    }

    func collectTyperefs(): ArrayList<(ItemId, clang.Type, clang.Cursor, ?ItemId)> {
        if (!this.collectedTyperefs) {
            this.collectedTyperefs = true
        } else {
            throw Exception("already collected")
        }

        let typerefs = ArrayList<(ItemId, clang.Type, clang.Cursor, ?ItemId)>()

        for ((id, item) in this.getItems()) {
            let kind = item.kind
            let ty = match (kind.asType()) {
                case Some(t) => t
                case None => continue
            }

            if (let TypeKind.UnresolvedTypeRef(ty, loc, parentId) <- ty.kind) {
                typerefs.add((id, ty, loc, parentId))
            }
        }

        return typerefs
    }

    func resolveTypeRefs() {
        let typerefs = this.collectTyperefs()

        for ((id, ty, loc, parentId) in typerefs) {
            let resolved = Item
                .fromTy(ty, loc, parentId, this)
                .unwrapOrElse {
                    _ =>
                    // eprintln("Could not resolve type reference, falling back to opaque blob")
                    Item.newOpaqueType(this.nextItemId(), ty, this)
                }

            let item = this.items[Int64(id)].getOrThrow()
            item.kind.expectType().kind = TypeKind.ResolvedTypeRef(resolved)
        }
    }

    // WARNING: The callback `f` must NOT call `resolveItem(id)` for the same `id` being loaned,
    // as the slot is temporarily set to None.
    func withLoanedItem<T>(id: ItemId, f: (CjbindContext, Item) -> T): T {
        let item = this.items[Int64(id)].getOrThrow()
        this.items[Int64(id)] = None

        let result = f(this, item)

        this.items[Int64(id)] = item

        return result
    }

    func computeBitfieldUnits() {
        let tnba = this.needBitfieldAllocation
        this.needBitfieldAllocation = ArrayList()

        for (id in tnba) {
            this.withLoanedItem(id) {
                ctx, item =>
                let ty = item.kind.asType().getOrThrow()
                let layout = ty.getLayout(ctx)
                ty.asComp().getOrThrow().computeBitfieldUnits(ctx, layout)
            }
        }
    }

    public func assignFieldNames(): Unit {
        let compItemIds = this
            .getItems()
            .filterMap {
                v =>
                let id = v[0]
                let item = v[1]

                let cond = item.kind.asType()?.isComp()
                let ret: ?ItemId = match (cond) {
                    case Some(v) =>
                        if (v) {
                            return Some(id)
                        } else {
                            return None<ItemId>
                        }
                    case None => None<ItemId>
                }
                return ret
            } |> collectArrayList

        for (id in compItemIds) {
            let canonicalTypeName = this.resolveItem(id).canonicalName(this)
            this.withLoanedItem(id) {
                ctx, item => item.kind.asType().getOrThrow().asComp().getOrThrow().assignFieldNames(ctx, canonicalTypeName)
            }
        }
    }

    public func isStdintType(name: String): Bool {
        match (name) {
            case "int8_t" | "uint8_t" | "int16_t" | "uint16_t" | "int32_t" | "uint32_t" | "int64_t" | "uint64_t" | "uintptr_t" | "intptr_t" | "ptrdiff_t" | "size_t" | "ssize_t" => true
            case _ => false
        }
    }

    public func isEnumTypedefCombo(id: ItemId): Bool {
        this.enumTypedefCombos?.contains(id) ?? false
    }

    func computeCodegenItems() {
        let roots = ArrayList<ItemId>()
        for ((id, item) in this.getItems()) {
            let include = match (item.kind) {
                case ItemKind.KindModule(_) => true
                case ItemKind.KindType(_) => this.options.generateTypes
                case ItemKind.KindVar(_) => this.options.generateVars
                case ItemKind.KindFunction(function) =>
                    match (function.kind) {
                        case FunctionKind.KindFunction => this.options.generateFunctions
                        case FunctionKind.KindMethod(MethodKind.Constructor) => this.options.generateConstructors
                        case FunctionKind.KindMethod(MethodKind.Destructor) |
                            FunctionKind.KindMethod(MethodKind.VirtualDestructor(_)) => this.options.generateDestructors
                        case FunctionKind.KindMethod(_) => this.options.generateMethods
                    }
            }
            if (include) {
                roots.add(id)
            }
        }
        roots.reverse()

        let found = ItemTraversal(this, roots.toArray()) |> collectArray
        this.codegenItems = Some(ItemSet(found))
    }

    // cjlint-ignore -start !G.FUN.01
    func computeEnumTypedefCombos() {
        let data = HashSet<ItemId>()

        for (item in this.getItems()) {
            if (let ItemKind.KindModule(module) <- item[1].kind) {
                let namesOfTypedefs = HashSet<String>()

                for (childId in module.children) {
                    if (let Some(ItemKind.KindType(ty)) <- this.items[Int64(childId)].flatMap {it => it.kind}) {
                        if (let (Some(name), TypeKind.TypeKindAlias(typeId)) <- (ty.name, ty.kind)) {
                            if (typeId
                                .intoResolver()
                                .throughTypeRefs()
                                .throughTypeAliases()
                                .resolve(this)
                                .kind
                                .asType()?.isInt() ?? false) {
                                namesOfTypedefs.add(name)
                            }
                        }
                    }
                }

                for (childId in module.children) {
                    if (let Some(ItemKind.KindType(ty)) <- this.items[Int64(childId)].flatMap {it => it.kind}) {
                        if (let (Some(name), true) <- (ty.name, ty.isEnum())) {
                            if (namesOfTypedefs.contains(name)) {
                                data.add(childId)
                            }
                        }
                    }
                }
            }
        }

        this.enumTypedefCombos = Some(data)
    }
    // cjlint-ignore -end

    public func gen<E>(cb: (CjbindContext) -> Result<TokenStream, E>): Result<TokenStream, E> {
        this.inCodegen = true

        this.resolveTypeRefs()
        this.populateTemplateInstantiations()
        this.computeBitfieldUnits()
        this.assignFieldNames()

        this.computeCodegenItems()

        this.computeEnumTypedefCombos()

        return cb(this)
    }
}

public class ItemResolver {
    let idVal: ItemId
    var throughTypeRefsVal: Bool = false
    var throughTypeAliasesVal: Bool = false

    public init(id: ItemId) {
        this.idVal = id
    }

    public func throughTypeRefs(): ItemResolver {
        this.throughTypeRefsVal = true
        return this
    }

    public func throughTypeAliases(): ItemResolver {
        this.throughTypeAliasesVal = true
        return this
    }

    public func resolve(ctx: CjbindContext): Item {
        var id = this.idVal
        var seenIds = HashSet<ItemId>()

        while (true) {
            let item = ctx.resolveItem(id)

            if (!seenIds.add(id)) {
                return item
            }

            let tyKind = item.asType().flatMap {t => t.kind}
            match (tyKind) {
                case Some(TypeKind.ResolvedTypeRef(nextId)) =>
                    if (this.throughTypeRefsVal) {
                        id = nextId
                    } else {
                        return item
                    }
                case Some(TypeKind.TypeKindAlias(nextId)) =>
                    if (this.throughTypeAliasesVal) {
                        id = nextId
                    } else {
                        return item
                    }
                case _ => return item
            }
        }

        throw Exception("unreachable")
    }
}

public interface IntoResolver {
    func intoResolver(): ItemResolver
}

extend ItemId <: IntoResolver {
    public func intoResolver(): ItemResolver {
        return ItemResolver(this)
    }
}
