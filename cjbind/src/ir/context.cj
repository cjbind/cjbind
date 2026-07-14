package cjbind.ir

import cjbind_token.*
import std.collection.*
import std.fs.Path
import std.env.getTempDirectory
import cjbind.result.Result
import cjbind.clang
import cjbind.options.{CjbindOptions, NamePatternSet}

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

    func numSelfTemplateParams(): Int64 {
        let kind = this.decl.kind()
        if (kind != clang.CXCursorKind_CXCursor_ClassTemplate &&
            kind != clang.CXCursorKind_CXCursor_FunctionTemplate &&
            kind != clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl) {
            return 0
        }

        let count = Box(0)
        this.decl.visit {
            child =>
            let childKind = child.kind()
            if (childKind == clang.CXCursorKind_CXCursor_TemplateTypeParameter ||
                childKind == clang.CXCursorKind_CXCursor_TemplateTemplateParameter ||
                childKind == clang.CXCursorKind_CXCursor_NonTypeTemplateParameter) {
                count.value += 1
            }
            clang.CXChildVisitResult_CXChildVisit_Continue
        }
        return count.value
    }
}

class CodegenTemplateMaterialization {
    let arguments: Array<TypeId>
    let wrapper: TypeId
    var failed: Bool = false

    init(arguments: Array<TypeId>, wrapper: TypeId) {
        this.arguments = arguments
        this.wrapper = wrapper
    }
}

class CodegenAliasUse {
    let definition: TypeId
    let arguments: Array<TypeId>

    init(definition: TypeId, arguments: Array<TypeId>) {
        this.definition = definition
        this.arguments = arguments
    }
}

public class CjbindContext <: Resource {
    var _released: Bool = false
    public let options: CjbindOptions

    public let items: ArrayList<?Item>
    public let types: HashMap<TypeKey, TypeId> = HashMap()
    public let modules: HashMap<clang.Cursor, ModuleId> = HashMap()
    public let typeParams: HashMap<clang.Cursor, TypeId> = HashMap()

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

    public var allowlistedItems: Option<ItemSet> = None
    public var codegenItems: Option<ItemSet> = None
    let codegenTemplateReplacements: HashMap<ItemId, TypeId> = HashMap()
    let codegenTemplateMaterializations: HashMap<ItemId, ArrayList<CodegenTemplateMaterialization>> = HashMap()
    let codegenAnalysisOrigins: HashMap<ItemId, ItemId> = HashMap()
    let codegenAliasUses: HashMap<ItemId, CodegenAliasUse> = HashMap()

    public var usedTemplateParameters: ?HashMap<ItemId, ItemSet> = None
    var haveVtable: ?HashMap<ItemId, HasVtableResult> = None
    var sizednessResults: ?HashMap<ItemId, SizednessResult> = None

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
        location: ?clang.Cursor
    ): Unit {
        let id = item.id
        let isType = item.kind.isType()
        let isUnnamed = item.kind.isType() && item.kind.expectType().name.isNone()
        let isTemplateInstantiation = if (isType) {
            match (item.kind.expectType().kind) {
                case TypeKind.TypeKindTemplateInstantiation(_) => true
                case _ => false
            }
        } else {
            false
        }

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

        if (!isType || isTemplateInstantiation) {
            return
        }

        if (let Some(sourceDeclaration) <- declaration) {
            var decl = sourceDeclaration
            if (!decl.isValid()) {
                if (let Some(sourceLocation) <- location) {
                    if (sourceLocation.isTemplateLike()) {
                        decl = sourceLocation
                    }
                }
            }
            decl = decl.canonical()
            if (!decl.isValid()) {
                return
            }
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
        let location = Some(ty.declaration().location())
        let typeKind = TypeKind.ResolvedTypeRef(wrapperId)
        let ity = Type(Some(spelling), layout, typeKind, isConst)
        let item = Item(
            withId,
            None,
            parentId.getOrDefault() {=> this.currentModule},
            ItemKind.KindType(ity),
            location
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

    func declarationInfoForTemplateInstantiation(
        instantiation: clang.Cursor
    ): ?(clang.Cursor, TypeId, Int64) {
        if (let Some(declaration) <- instantiation.curType().canonicalDeclaration(Some(instantiation))) {
            if (let Some(templateId) <- this.getResolvedType(declaration)) {
                let parameterCount = selfTemplateParams(templateId, this).size
                if (parameterCount > 0) {
                    return Some((declaration.cursor, templateId, parameterCount))
                }
            }
        }

        let referenced = match (instantiation.referenced()) {
            case Some(value) => value
            case None => return None
        }
        for (partial in this.currentlyParsedTypes) {
            if (partial.decl == referenced) {
                let parameterCount = partial.numSelfTemplateParams()
                if (parameterCount > 0) {
                    return Some((partial.decl, partial.id, parameterCount))
                }
            }
        }
        return None
    }

    func instantiateTemplate(
        withId: ItemId,
        template: TypeId,
        ty: clang.Type,
        location: clang.Cursor
    ): ?TypeId {
        let expectedArgumentCount = selfTemplateParams(template, this).size
        if (expectedArgumentCount == 0) {
            eprintln(
                "Warning: unable to inspect a C++ template instantiation because its template parameters are unknown"
            )
            return None
        }

        var children = location.collectChildren()
        var childrenAreFlat = true
        for (child in children) {
            if (!child.collectChildren().isEmpty()) {
                childrenAreFlat = false
                break
            }
        }
        if (childrenAreFlat) {
            var templateReferenceIndex: ?Int64 = None
            for ((index, child) in children.iterator().enumerate()) {
                if (child.kind() == clang.CXCursorKind_CXCursor_TemplateRef) {
                    templateReferenceIndex = Some(index)
                    break
                }
            }
            if (let Some(index) <- templateReferenceIndex) {
                var onlyNamespacesBeforeTemplate = true
                for (prefixIndex in 0..index) {
                    if (children[prefixIndex].kind() != clang.CXCursorKind_CXCursor_NamespaceRef) {
                        onlyNamespacesBeforeTemplate = false
                        break
                    }
                }
                if (onlyNamespacesBeforeTemplate) {
                    let remaining = ArrayList<clang.Cursor>()
                    for (childIndex in (index + 1)..children.size) {
                        remaining.add(children[childIndex])
                    }
                    children = remaining
                }
            }
        }

        let arguments = ArrayList<TypeId>()
        var foundNonTypeArgument = false
        children.reverse()
        for (child in children) {
            let childKind = child.kind()
            if (childKind == clang.CXCursorKind_CXCursor_TypeRef ||
                childKind == clang.CXCursorKind_CXCursor_TypedefDecl ||
                childKind == clang.CXCursorKind_CXCursor_TypeAliasDecl) {
                arguments.add(Item.fromTyOrRef(
                    child.curType(),
                    child,
                    Some(template),
                    this
                ))
            } else if (childKind == clang.CXCursorKind_CXCursor_TemplateRef) {
                let declarationInfo = match (this.declarationInfoForTemplateInstantiation(child)) {
                    case Some(value) => value
                    case None => return None
                }
                let (templateCursor, templateId, nestedArgumentCount) = declarationInfo
                let nestedChildren = child.collectChildren()
                if (nestedArgumentCount == 0 || nestedChildren.size >= nestedArgumentCount) {
                    arguments.add(Item.fromTyOrRef(
                        child.curType(),
                        child,
                        Some(template),
                        this
                    ))
                } else {
                    if (arguments.size < nestedArgumentCount) {
                        eprintln(
                            "Warning: found a C++ template instantiation without enough type arguments"
                        )
                        return None
                    }
                    let nestedArguments = ArrayList<TypeId>()
                    let start = arguments.size - nestedArgumentCount
                    for (index in start..arguments.size) {
                        nestedArguments.add(arguments[index])
                    }
                    for (_ in 0..nestedArgumentCount) {
                        arguments.remove(at: arguments.size - 1)
                    }
                    nestedArguments.reverse()
                    let nestedInstantiation = TemplateInstantiation(
                        templateId,
                        nestedArguments.toArray()
                    )
                    let nestedId = this.nextItemId()
                    this.addItem(
                        Item(
                            nestedId,
                            None,
                            this.currentModule,
                            ItemKind.KindType(Type(
                                Some(templateCursor.spelling()),
                                templateCursor.curType().fallibleLayout(this).ok(),
                                TypeKind.TypeKindTemplateInstantiation(nestedInstantiation),
                                false
                            )),
                            Some(child.location())
                        ),
                        None,
                        Some(child)
                    )
                    arguments.add(nestedId)
                }
            } else {
                eprintln(
                    "Warning: found an unsupported C++ template argument cursor '${child.spelling()}'"
                )
                foundNonTypeArgument = true
            }
        }

        if (foundNonTypeArgument) {
            eprintln("Warning: C++ templates with non-type arguments are not supported")
            return None
        }
        if (arguments.size != expectedArgumentCount) {
            eprintln(
                "Warning: found a C++ template instantiation with an unexpected number of type arguments"
            )
            return None
        }

        arguments.reverse()
        let instantiation = TemplateInstantiation(template, arguments.toArray())
        let name = ty.spelling()
        let item = Item(
            withId,
            None,
            this.currentModule,
            ItemKind.KindType(Type(
                if (name.isEmpty()) { None } else { Some(name) },
                ty.fallibleLayout(this).ok(),
                TypeKind.TypeKindTemplateInstantiation(instantiation),
                ty.isConst()
            )),
            Some(location.location())
        )
        this.addItem(item, None, Some(location))
        return Some(withId)
    }

    public func builtinOrResolvedTy(
        withId: ItemId,
        parentId: ?ItemId,
        ty: clang.Type,
        location: ?clang.Cursor
    ): ?TypeId {
        if (let Some(decl) <- ty.canonicalDeclaration(location)) {
            if (let Some(tid) <- this.getResolvedType(decl)) {
                if (let Some(instantiationCursor) <- location && decl.cursor.isTemplateLike() &&
                    ty != decl.cursor.curType()) {
                    var containsTypeRef = false
                    for (child in instantiationCursor.collectChildren()) {
                        if (child.kind() == clang.CXCursorKind_CXCursor_TypeRef) {
                            containsTypeRef = true
                            break
                        }
                    }
                    let canonicalType = ty.canonicalType()
                    if (decl.cursor.kind() == clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl &&
                        !containsTypeRef && canonicalType.isValid() &&
                        canonicalType.kind() != clang.CXTypeKind_CXType_Unexposed) {
                        return None
                    }
                    return match (this.instantiateTemplate(
                        withId,
                        tid,
                        ty,
                        instantiationCursor
                    )) {
                        case Some(value) => Some(value)
                        case None => Some(tid)
                    }
                }
                return Some(this.buildTyWrapper(withId, tid, parentId, ty))
            }
        }

        return this.buildBuiltinTy(ty)
    }

    public func beginParsing(partialTy: PartialType): Unit {
        this.currentlyParsedTypes.add(partialTy)
    }

    public func finishParsing(): PartialType {
        let ret = this.currentlyParsedTypes.last
        this.currentlyParsedTypes.remove(at: this.currentlyParsedTypes.size - 1)
        match (ret) {
            case Some(value) => return value
            case None => throw Exception("finish parsing without begin")
        }
    }

    public func resolveItemFallible(id: ItemId): ?Item {
        return match (this.items.get(Int64(id))) {
            case Some(value) => value
            case None => None
        }
    }

    public func resolveItem(itemId: ItemId): Item {
        return this.resolveItemFallible(itemId).getOrThrow()
    }

    public func resolveType(typeId: TypeId): Type {
        return this.resolveItem(typeId).kind.expectType()
    }

    public func safeResolveType(typeId: TypeId): ?Type {
        return this.resolveItemFallible(typeId).flatMap {item => item.kind.asType()}
    }

    public func templateInstantiationFor(id: ItemId): ?TemplateInstantiation {
        let ty = match (this.safeResolveType(id)) {
            case Some(value) => value
            case None => return None
        }
        return match (ty.kind) {
            case TypeKind.TypeKindTemplateInstantiation(instantiation) => Some(instantiation)
            case _ => None
        }
    }

    public func codegenTemplateReplacement(id: ItemId): ?TypeId {
        return this.codegenTemplateReplacements.get(id)
    }

    public func codegenAliasUse(id: ItemId): ?(TypeId, Array<TypeId>) {
        return this.codegenAliasUses.get(id).map({use => (use.definition, use.arguments)})
    }

    func sameTemplateArguments(left: Array<TypeId>, right: Array<TypeId>): Bool {
        if (left.size != right.size) {
            return false
        }
        for (index in 0..left.size) {
            if (left[index] != right[index]) {
                return false
            }
        }
        return true
    }

    func findCodegenTemplateMaterialization(
        definition: ItemId,
        arguments: Array<TypeId>
    ): ?CodegenTemplateMaterialization {
        if (let Some(entries) <- this.codegenTemplateMaterializations.get(definition)) {
            for (entry in entries) {
                if (this.sameTemplateArguments(entry.arguments, arguments)) {
                    return Some(entry)
                }
            }
        }
        return None
    }

    func addCodegenTemplateMaterialization(
        definition: ItemId,
        materialization: CodegenTemplateMaterialization
    ): Unit {
        let entries = match (this.codegenTemplateMaterializations.get(definition)) {
            case Some(value) => value
            case None =>
                let value = ArrayList<CodegenTemplateMaterialization>()
                this.codegenTemplateMaterializations.add(definition, value)
                value
        }
        entries.add(materialization)
    }

    func addLoweredType(sourceItem: Item, sourceType: Type, kind: TypeKind, parentId: ItemId): TypeId {
        let id = this.nextItemId()
        this.addItem(
            Item(
                id,
                sourceItem.comment,
                parentId,
                ItemKind.KindType(Type(sourceType.name, sourceType.layout, kind, sourceType.isConst)),
                sourceItem.location
            ),
            None,
            None
        )
        return id
    }

    func lowerTemplateAliasUse(
        sourceItem: Item,
        source: Type,
        substitutions: HashMap<TypeId, TypeId>,
        ownerId: ItemId,
        failed: Box<Bool>
    ): TypeId {
        let arguments = ArrayList<TypeId>()
        for (parameter in this.usedTemplateParams(sourceItem.id)) {
            let argument = match (substitutions.get(parameter)) {
                case Some(value) => value
                case None => match (substitutions.get(canonicalItemId(this, parameter))) {
                    case Some(value) => value
                    case None =>
                        failed.value = true
                        return sourceItem.id
                }
            }
            arguments.add(argument)
        }
        if (arguments.isEmpty()) {
            return sourceItem.id
        }
        let lowered = this.addLoweredType(sourceItem, source, source.kind, ownerId)
        this.codegenAliasUses.add(
            lowered,
            CodegenAliasUse(sourceItem.id, arguments.toArray())
        )
        return lowered
    }

    func lowerTemplateType(
        sourceId: TypeId,
        substitutions: HashMap<TypeId, TypeId>,
        ownerId: ItemId,
        failed: Box<Bool>
    ): TypeId {
        if (let Some(substituted) <- substitutions.get(sourceId)) {
            return substituted
        }
        let canonical = canonicalItemId(this, sourceId)
        if (let Some(substituted) <- substitutions.get(canonical)) {
            return substituted
        }
        let sourceItem = match (this.resolveItemFallible(sourceId)) {
            case Some(value) => value
            case None => return sourceId
        }
        let source = match (sourceItem.kind.asType()) {
            case Some(value) => value
            case None => return sourceId
        }

        let kind: ?TypeKind = match (source.kind) {
            case TypeKind.TypeKindTypeParam =>
                failed.value = true
                return sourceId
            case TypeKind.ResolvedTypeRef(inner) =>
                return this.lowerTemplateType(inner, substitutions, ownerId, failed)
            case TypeKind.TypeKindAlias(_) | TypeKind.TypeKindTemplateAlias(_, _) =>
                return this.lowerTemplateAliasUse(
                    sourceItem,
                    source,
                    substitutions,
                    ownerId,
                    failed
                )
            case TypeKind.TypeKindPointer(inner) =>
                let lowered = this.lowerTemplateType(inner, substitutions, ownerId, failed)
                if (lowered == inner) {
                    return sourceId
                }
                TypeKind.TypeKindPointer(lowered)
            case TypeKind.TypeKindReference(inner) =>
                let lowered = this.lowerTemplateType(inner, substitutions, ownerId, failed)
                if (lowered == inner) {
                    return sourceId
                }
                TypeKind.TypeKindReference(lowered)
            case TypeKind.TypeKindArray(inner, length) =>
                let lowered = this.lowerTemplateType(inner, substitutions, ownerId, failed)
                if (lowered == inner) {
                    return sourceId
                }
                TypeKind.TypeKindArray(lowered, length)
            case TypeKind.TypeKindVector(inner, length) =>
                let lowered = this.lowerTemplateType(inner, substitutions, ownerId, failed)
                if (lowered == inner) {
                    return sourceId
                }
                TypeKind.TypeKindVector(lowered, length)
            case TypeKind.TypeKindObjCBlockPointer(inner) =>
                let lowered = this.lowerTemplateType(inner, substitutions, ownerId, failed)
                if (lowered == inner) {
                    return sourceId
                }
                TypeKind.TypeKindObjCBlockPointer(lowered)
            case TypeKind.TypeKindFunction(signature) =>
                let arguments = ArrayList<(?String, TypeId)>()
                var changed = false
                for ((name, argument) in signature.argumentTypes) {
                    let lowered = this.lowerTemplateType(
                        argument,
                        substitutions,
                        ownerId,
                        failed
                    )
                    changed ||= lowered != argument
                    arguments.add((name, lowered))
                }
                let returnType = this.lowerTemplateType(
                    signature.returnType,
                    substitutions,
                    ownerId,
                    failed
                )
                changed ||= returnType != signature.returnType
                if (!changed) {
                    return sourceId
                }
                TypeKind.TypeKindFunction(FunctionSig(
                    signature.name,
                    returnType,
                    arguments.toArray(),
                    signature.rawIsVariadic(),
                    signature.abi,
                    valueAbiUnsupported: signature.valueAbiUnsupported
                ))
            case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
                let arguments = ArrayList<TypeId>()
                for (argument in instantiation.arguments) {
                    arguments.add(this.lowerTemplateType(
                        argument,
                        substitutions,
                        ownerId,
                        failed
                    ))
                }
                return this.lowerTemplateInstantiationType(
                    sourceItem,
                    source,
                    TemplateInstantiation(instantiation.definition, arguments.toArray()),
                    ownerId,
                    failed
                )
            case TypeKind.TypeKindComp(info) =>
                if (!this.usesAnyTemplateParameters(sourceId)) {
                    return sourceId
                }
                failed.value = true
                return sourceId
            case TypeKind.UnresolvedTypeRef(_, _, _) =>
                failed.value = true
                return sourceId
            case _ => return sourceId
        }

        let loweredKind = kind.getOrThrow()
        return this.addLoweredType(sourceItem, source, loweredKind, ownerId)
    }

    func lowerTemplateFieldData(
        data: FieldData,
        substitutions: HashMap<TypeId, TypeId>,
        ownerId: ItemId,
        failed: Box<Bool>
    ): FieldData {
        return FieldData(
            data.name,
            this.lowerTemplateType(data.ty, substitutions, ownerId, failed),
            data.comment,
            data.bitfieldWidth,
            data.offset,
            isPublic: data.isPublic
        )
    }

    func lowerTemplateComp(
        definition: CompInfo,
        ownerId: ItemId,
        substitutions: HashMap<TypeId, TypeId>,
        failed: Box<Bool>
    ): CompInfo {
        let concrete = CompInfo(definition.kind, isCxxRecord: definition.isCxxRecord)
        concrete.isForwardDeclaration = definition.isForwardDeclaration
        concrete.packedAttr = definition.packedAttr
        concrete.hasUnevaluableBitFieldWidth = definition.hasUnevaluableBitFieldWidth
        concrete.foundUnknownAttr = definition.foundUnknownAttr
        concrete.hasOwnVirtualMethod = definition.hasOwnVirtualMethod
        concrete.hasDestructor = definition.hasDestructor
        concrete.hasUnrepresentedVirtualMethod = definition.hasUnrepresentedVirtualMethod ||
            definition.methods.iterator().any({method => method.kind.isVirtual()})

        let value = match (definition.fields) {
            case CompFields.CompFieldsAfter(fields) => fields
            case CompFields.CompFieldsError | CompFields.CompFieldsBefore(_) =>
                failed.value = true
                return concrete
        }
        let fields = ArrayList<Field>()
        for (field in value.fields) {
            match (field) {
                case Field.DataMember(data) => fields.add(Field.DataMember(
                    this.lowerTemplateFieldData(data, substitutions, ownerId, failed)
                ))
                case Field.Bitfields(unit) =>
                    let bitfields = ArrayList<Bitfield>()
                    for (bitfield in unit.bitfields) {
                        bitfields.add(Bitfield(
                            bitfield.offsetIntoUnit,
                            this.lowerTemplateFieldData(bitfield.data, substitutions, ownerId, failed)
                        ))
                    }
                    fields.add(Field.Bitfields(BitfieldUnit(
                        unit.nth,
                        unit.layout,
                        bitfields.toArray()
                    )))
            }
        }
        concrete.fields = CompFields.CompFieldsAfter(CompFieldsAfterValue(
            fields.toArray(),
            value.hasBitfieldUnits
        ))
        for (base in definition.baseMembers) {
            concrete.baseMembers.add(Base(
                this.lowerTemplateType(base.ty, substitutions, ownerId, failed),
                base.kind,
                base.fieldName,
                base.isPublic
            ))
        }
        for (innerType in definition.innerTypes) {
            if (!this.usesAnyTemplateParameters(innerType)) {
                concrete.innerTypes.add(innerType)
            }
        }
        return concrete
    }

    func templateCompHasExactLayoutEvidence(concrete: CompInfo, layout: Layout): Bool {
        if (concrete.foundUnknownAttr || !concrete.baseMembers.isEmpty() ||
            concrete.hasOwnVirtualMethod || concrete.hasUnrepresentedVirtualMethod) {
            return false
        }
        let hasOnlyOrdinaryFields = match (concrete.fields) {
            case CompFields.CompFieldsAfter(value) => value.fields.all {
                field => match (field) {
                    case Field.DataMember(_) => true
                    case Field.Bitfields(_) => false
                }
            }
            case CompFields.CompFieldsBefore(_) | CompFields.CompFieldsError => false
        }
        return hasOnlyOrdinaryFields && concrete.generatedRecordLayoutMatches(this, layout)
    }

    func concreteTemplateLayout(source: Type): ?Layout {
        if (let Some(layout) <- source.layout) {
            return Some(layout)
        }
        let spelling = match (source.name) {
            case Some(value) => value
            case None => return None
        }
        return this.tryEnsureFallbackTranslationUnit()
            .flatMap({fallback => fallback.probeType(spelling)})
            .flatMap({ty => ty.fallibleLayout(this).ok()})
    }

    func codegenTemplateArguments(
        definition: ItemId,
        parameters: Array<TypeId>,
        arguments: Array<TypeId>
    ): Array<TypeId> {
        let used = this.usedTemplateParams(definition)
        let result = ArrayList<TypeId>()
        let count = min(parameters.size, arguments.size)
        for (index in 0..count) {
            if (used.contains(parameters[index])) {
                result.add(arguments[index])
            }
        }
        return result.toArray()
    }

    func opaqueTemplateComp(concrete: CompInfo): CompInfo {
        let opaque = CompInfo(concrete.kind, isCxxRecord: concrete.isCxxRecord)
        opaque.fields = CompFields.CompFieldsError
        return opaque
    }

    func lowerTemplateInstantiationType(
        sourceItem: Item,
        source: Type,
        instantiation: TemplateInstantiation,
        ownerId: ItemId,
        failed: Box<Bool>
    ): TypeId {
        let definitionItem = instantiation.definition
            .intoResolver()
            .throughTypeRefs()
            .resolve(this)
        if (this.isBlocklistedItem(definitionItem.id)) {
            failed.value = true
            return sourceItem.id
        }
        let parameters = selfTemplateParams(definitionItem.id, this)
        let definitionType = match (definitionItem.kind.asType()) {
            case Some(value) => value
            case None => return sourceItem.id
        }
        if (let TypeKind.TypeKindTemplateAlias(_, _) <- definitionType.kind) {
            let unchanged = match (source.kind) {
                case TypeKind.TypeKindTemplateInstantiation(original) =>
                    original.definition == instantiation.definition &&
                        this.sameTemplateArguments(original.arguments, instantiation.arguments)
                case _ => false
            }
            if (unchanged) {
                return sourceItem.id
            }
            return this.addLoweredType(
                sourceItem,
                source,
                TypeKind.TypeKindTemplateInstantiation(instantiation),
                ownerId
            )
        }
        if (parameters.isEmpty()) {
            return sourceItem.id
        }
        if (sourceItem.isSemanticallyOpaque(this)) {
            return sourceItem.id
        }

        let definition = match (definitionType.asComp()) {
            case Some(value) => value
            case None => return sourceItem.id
        }
        if (this.usedTemplateParams(definitionItem.id).isEmpty()) {
            return definitionItem.id
        }

        let codegenArguments = this.codegenTemplateArguments(
            definitionItem.id,
            parameters,
            instantiation.arguments
        )

        if (let Some(existing) <- this.findCodegenTemplateMaterialization(
            definitionItem.id,
            codegenArguments
        )) {
            if (existing.failed) {
                failed.value = true
            }
            return existing.wrapper
        }

        let concreteId = this.addLoweredType(
            sourceItem,
            source,
            TypeKind.TypeKindTemplateInstantiation(TemplateInstantiation(
                instantiation.definition,
                codegenArguments
            )),
            this.rootModule
        )
        let concreteItem = this.resolveItem(concreteId)
        let wrapperName = concreteItem.fullDisambiguatedName(this)

        let materialization = CodegenTemplateMaterialization(codegenArguments, concreteId)
        this.addCodegenTemplateMaterialization(definitionItem.id, materialization)
        let substitutions = HashMap<TypeId, TypeId>()
        substitutions.add(instantiation.definition, concreteId)
        substitutions.add(definitionItem.id, concreteId)
        substitutions.add(canonicalItemId(this, definitionItem.id), concreteId)
        let substitutionCount = min(parameters.size, instantiation.arguments.size)
        for (index in 0..substitutionCount) {
            let parameter = parameters[index]
            let argument = instantiation.arguments[index]
            substitutions.add(parameter, argument)
            substitutions.add(canonicalItemId(this, parameter), argument)
        }
        let concrete = this.lowerTemplateComp(definition, concreteId, substitutions, failed)
        if (failed.value) {
            materialization.failed = true
            return concreteId
        }

        let concreteLayout = match (this.concreteTemplateLayout(source)) {
            case Some(value) => value
            case None =>
                failed.value = true
                materialization.failed = true
                return concreteId
        }

        let emitted = if (this.templateCompHasExactLayoutEvidence(concrete, concreteLayout)) {
            concrete
        } else {
            this.opaqueTemplateComp(concrete)
        }
        concreteItem.kind = ItemKind.KindType(Type(
            Some(wrapperName),
            Some(concreteLayout),
            TypeKind.TypeKindComp(emitted),
            source.isConst
        ))
        this.codegenAnalysisOrigins.add(concreteId, sourceItem.id)
        this.codegenItems.getOrThrow().add(concreteId)
        return concreteId
    }

    func lowerTemplateInstantiationsForCodegen(): Unit {
        let candidates = ArrayList<(TypeId, TemplateInstantiation)>()
        for (id in this.codegenItems.getOrThrow()) {
            if (let Some(ty) <- this.safeResolveType(id)) {
                if (let TypeKind.TypeKindTemplateInstantiation(instantiation) <- ty.kind) {
                    candidates.add((id, instantiation))
                }
            }
        }
        for ((id, instantiation) in candidates) {
            if (this.usesAnyTemplateParameters(id)) {
                continue
            }
            let item = this.resolveItem(id)
            let source = item.kind.expectType()
            let failed = Box(false)
            let substitutions = HashMap<TypeId, TypeId>()
            let arguments = ArrayList<TypeId>()
            for (argument in instantiation.arguments) {
                arguments.add(this.lowerTemplateType(
                    argument,
                    substitutions,
                    this.rootModule,
                    failed
                ))
            }
            if (failed.value) {
                continue
            }
            let lowered = this.lowerTemplateInstantiationType(
                item,
                source,
                TemplateInstantiation(instantiation.definition, arguments.toArray()),
                this.rootModule,
                failed
            )
            if (!failed.value && lowered != id) {
                this.codegenTemplateReplacements.add(id, lowered)
            }
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
            case "int8_t" | "uint8_t" | "int16_t" | "uint16_t" | "int32_t" | "uint32_t" | "int64_t" | "uint64_t" | "uintptr_t" | "intptr_t" | "ptrdiff_t" => true
            case "size_t" | "ssize_t" => this.options.sizeTIsUsize
            case _ => false
        }
    }

    public func isEnumTypedefCombo(id: ItemId): Bool {
        this.enumTypedefCombos?.contains(id) ?? false
    }

    public func itemPolicyName(item: Item): String {
        return item.policyName(this)
    }

    public func isBlocklistedItem(id: ItemId): Bool {
        let item = this.resolveItem(id)
        if (item.annotations.hide()) {
            return true
        }
        let name = this.itemPolicyName(item)
        if (this.options.blocklistedFiles.size != 0) {
            if (let Some(location) <- item.location) {
                let (file, _, _, _) = location.location()
                if (let Some(filename) <- file.name()) {
                    if (this.options.blocklistedFiles.matches(filename)) {
                        return true
                    }
                }
            }
        }
        if (this.options.blocklistedItems.matches(name)) {
            return true
        }
        return match (item.kind) {
            case ItemKind.KindType(_) => this.options.blocklistedTypes.matches(name)
            case ItemKind.KindFunction(_) => this.options.blocklistedFunctions.matches(name)
            case ItemKind.KindVar(_) => this.options.blocklistedVars.matches(name)
            case _ => false
        }
    }

    public func isOpaqueByName(item: Item): Bool {
        if (!item.kind.isType()) {
            return false
        }
        if (this.options.opaqueTypes.matches(this.itemPolicyName(item))) {
            return true
        }
        let instantiation = match (this.templateInstantiationFor(item.id)) {
            case Some(value) => value
            case None => return false
        }
        let definitionName = this.itemPolicyName(this.resolveItem(instantiation.definition))
        let argumentNames = Array<String>(instantiation.arguments.size) {
            index => this.itemPolicyName(this.resolveItem(instantiation.arguments[index]))
        }
        let instantiatedName = "${definitionName}<${String.join(argumentNames, delimiter: ", ")}>"
        return this.options.opaqueTypes.matches(instantiatedName)
    }

    public func usesTemplateParameter(id: ItemId, parameter: TypeId): Bool {
        if (this.isBlocklistedItem(id)) {
            return true
        }
        let canonicalParameter = canonicalItemId(this, parameter)
        return match (this.usedTemplateParameters) {
            case Some(results) => results.get(id)
                .map({parameters => parameters.contains(canonicalParameter)})
                .getOrDefault({=> false})
            case None => throw Exception("template parameter usage analysis has not been computed")
        }
    }

    public func usedTemplateParams(id: ItemId): Array<TypeId> {
        if (this.isBlocklistedItem(id)) {
            return allTemplateParams(id, this)
        }
        let result = ArrayList<TypeId>()
        let used = match (this.usedTemplateParameters) {
            case Some(results) => results.get(id).getOrDefault({=> ItemSet()})
            case None => throw Exception("template parameter usage analysis has not been computed")
        }
        for (parameter in allTemplateParams(id, this)) {
            let canonical = canonicalItemId(this, parameter)
            if (used.contains(canonical)) {
                result.add(parameter)
            }
        }
        return result.toArray()
    }

    public func usesAnyTemplateParameters(id: ItemId): Bool {
        return match (this.usedTemplateParameters) {
            case Some(results) => results.get(id).map({parameters => !parameters.isEmpty()}).getOrDefault({=> false})
            case None => throw Exception("template parameter usage analysis has not been computed")
        }
    }

    func vtableResult(id: ItemId): HasVtableResult {
        let analysisId = this.codegenAnalysisOrigins.get(id).getOrDefault({=> id})
        return match (this.haveVtable) {
            case Some(results) => results.get(analysisId).getOrDefault({=> HasVtableResult.No})
            case None => throw Exception("vtable analysis has not been computed")
        }
    }

    func hasVtable(id: ItemId): Bool {
        return this.vtableResult(id) != HasVtableResult.No
    }

    public func hasVtablePointer(id: ItemId): Bool {
        return this.vtableResult(id) == HasVtableResult.SelfHasVtable
    }

    func sizedness(id: TypeId): SizednessResult {
        let analysisId = this.codegenAnalysisOrigins.get(id).getOrDefault({=> id})
        return match (this.sizednessResults) {
            case Some(results) => results.get(analysisId).getOrDefault({=> SizednessResult.ZeroSized})
            case None => throw Exception("sizedness analysis has not been computed")
        }
    }

    public func isZeroSized(id: TypeId): Bool {
        return this.sizedness(id) == SizednessResult.ZeroSized
    }

    func computeCoreAnalyses(): Unit {
        let items = this.allowlistedItems.getOrThrow()
        this.haveVtable = Some(computeHasVtable(this, items))
        this.sizednessResults = Some(computeSizedness(this, items, this.haveVtable.getOrThrow()))
        this.usedTemplateParameters = Some(this.computeUsedTemplateParameterUsage(items))
    }

    func computeUsedTemplateParameterUsage(items: ItemSet): HashMap<ItemId, ItemSet> {
        if (this.options.allowlistRecursively) {
            return analyzeUsedTemplateParameters(this, items)
        } else {
            let usage = HashMap<ItemId, ItemSet>()
            for (id in items) {
                let parameters = ItemSet()
                for (parameter in selfTemplateParams(id, this)) {
                    parameters.add(parameter)
                }
                usage.add(id, parameters)
            }
            return usage
        }
    }

    func isEnabledForCodegen(item: Item): Bool {
        return match (item.kind) {
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
    }

    func hasExplicitAllowlist(): Bool {
        return this.options.allowlistedTypes.size != 0 ||
            this.options.allowlistedFunctions.size != 0 ||
            this.options.allowlistedVars.size != 0 ||
            this.options.allowlistedFiles.size != 0 ||
            this.options.allowlistedItems.size != 0
    }

    func isAllowlistedByFile(item: Item): Bool {
        if (this.options.allowlistedFiles.size == 0) {
            return false
        }
        if (let Some(location) <- item.location) {
            let (file, _, _, _) = location.location()
            if (let Some(filename) <- file.name()) {
                return this.options.allowlistedFiles.matches(filename)
            }
        }
        return false
    }

    func isUnnamedTopLevelEnumAllowlisted(item: Item, ty: Type): Bool {
        if (ty.name.isSome() || !this.resolveItem(item.parentId).kind.isModule()) {
            return false
        }
        let enumInfo = match (ty.kind) {
            case TypeKind.TypeKindEnum(value) => value
            case _ => return false
        }
        let parentPrefix = if (item.parentId == this.rootModule) {
            ""
        } else {
            this.itemPolicyName(this.resolveItem(item.parentId))
        }
        for (variant in enumInfo.variants) {
            let name = if (parentPrefix.isEmpty()) {
                variant.name
            } else {
                "${parentPrefix}::${variant.name}"
            }
            if (this.options.allowlistedVars.matches(name) ||
                this.options.allowlistedItems.matches(name)) {
                return true
            }
        }
        return false
    }

    func isBuiltinAllowlistSupportType(ty: Type, name: String): Bool {
        if (this.isStdintType(name)) {
            return true
        }
        return match (ty.kind) {
            case TypeKind.TypeKindVoid |
                TypeKind.TypeKindNullPtr |
                TypeKind.TypeKindInt(_) |
                TypeKind.TypeKindFloat(_) |
                TypeKind.TypeKindComplex(_) |
                TypeKind.TypeKindArray(_, _) |
                TypeKind.TypeKindVector(_, _) |
                TypeKind.TypeKindPointer(_) |
                TypeKind.TypeKindReference(_) |
                TypeKind.TypeKindFunction(_) |
                TypeKind.ResolvedTypeRef(_) |
                TypeKind.TypeKindOpaque |
                TypeKind.TypeKindTypeParam => true
            case _ => false
        }
    }

    func isExplicitAllowlistRoot(item: Item): Bool {
        if (!this.hasExplicitAllowlist()) {
            return true
        }
        if (item.kind.isModule() || this.isAllowlistedByFile(item)) {
            return true
        }
        let name = this.itemPolicyName(item)
        if (this.options.allowlistedItems.matches(name)) {
            return true
        }
        return match (item.kind) {
            case ItemKind.KindModule(_) => true
            case ItemKind.KindFunction(_) => this.options.allowlistedFunctions.matches(name)
            case ItemKind.KindVar(_) => this.options.allowlistedVars.matches(name)
            case ItemKind.KindType(ty) =>
                this.options.allowlistedTypes.matches(name) ||
                    (!this.options.allowlistRecursively && this.isBuiltinAllowlistSupportType(ty, name)) ||
                    this.isUnnamedTopLevelEnumAllowlisted(item, ty)
        }
    }

    func codegenTraversalEdge(_: CjbindContext, edge: Edge): Bool {
        return match (edge.kind) {
            case EdgeKind.GenericEdge => this.isEnabledForCodegen(this.resolveItem(edge.to))
            case EdgeKind.TemplateParameterDefinitionEdge |
                EdgeKind.TemplateArgumentEdge |
                EdgeKind.TemplateDeclarationEdge |
                EdgeKind.BaseMemberEdge |
                EdgeKind.FieldEdge |
                EdgeKind.InnerTypeEdge |
                EdgeKind.FunctionReturnEdge |
                EdgeKind.FunctionParameterEdge |
                EdgeKind.VarTypeEdge |
                EdgeKind.TypeReferenceEdge => this.options.generateTypes
            case EdgeKind.InnerVarEdge => this.options.generateVars
            case EdgeKind.MethodEdge => this.options.generateMethods
            case EdgeKind.ConstructorEdge => this.options.generateConstructors
            case EdgeKind.DestructorEdge => this.options.generateDestructors
        }
    }

    func collectUnblockedTraversal(
        roots: Array<ItemId>,
        predicate: (CjbindContext, Edge) -> Bool
    ): ItemSet {
        let result = ItemSet()
        for (id in ItemTraversal(this, roots, predicate)) {
            if (!this.isBlocklistedItem(id)) {
                result.add(id)
            }
        }
        return result
    }

    func reportUnmatchedAllowlistPatterns(): Unit {
        if (!this.options.recordMatches) {
            return
        }
        for ((flag, patterns) in [
            ("--allowlist-type", this.options.allowlistedTypes.unmatchedPatterns()),
            ("--allowlist-function", this.options.allowlistedFunctions.unmatchedPatterns()),
            ("--allowlist-var", this.options.allowlistedVars.unmatchedPatterns()),
            ("--allowlist-item", this.options.allowlistedItems.unmatchedPatterns())
        ]) {
            for (pattern in patterns) {
                eprintln("Warning: ${flag} pattern '${pattern}' did not match any item")
            }
        }
    }

    func computeCodegenItems() {
        let roots = ArrayList<ItemId>()
        for ((id, item) in this.getItems()) {
            if (this.isEnabledForCodegen(item) && this.isExplicitAllowlistRoot(item)) {
                roots.add(id)
            }
        }
        roots.reverse()

        let allowlistedPredicate: (CjbindContext, Edge) -> Bool = if (this.options.allowlistRecursively) {
            {_ctx, _edge => true}
        } else {
            {_ctx, edge => match (edge.kind) {
                case EdgeKind.InnerTypeEdge => true
                case _ => false
            }}
        }
        let allowlisted = this.collectUnblockedTraversal(roots.toArray(), allowlistedPredicate)
        let generated = if (this.options.allowlistRecursively) {
            this.collectUnblockedTraversal(
                roots.toArray(),
                {ctx, edge => this.codegenTraversalEdge(ctx, edge)}
            )
        } else {
            let copy = ItemSet()
            for (id in allowlisted) {
                copy.add(id)
            }
            copy
        }
        this.allowlistedItems = Some(allowlisted)
        this.codegenItems = Some(generated)
        this.reportUnmatchedAllowlistPatterns()
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
        this.computeBitfieldUnits()
        this.assignFieldNames()

        this.computeCodegenItems()
        this.computeCoreAnalyses()
        this.computeEnumTypedefCombos()

        this.lowerTemplateInstantiationsForCodegen()

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
                case Some(TypeKind.TypeKindTemplateAlias(nextId, _)) =>
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
