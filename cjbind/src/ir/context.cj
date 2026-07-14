package cjbind.ir

import cjbind_token.*
import std.collection.*
import std.fs.Path
import std.env.getTempDirectory
import cjbind.result.Result
import cjbind.clang
import cjbind.options.{CjbindOptions, ConfiguredCanDerive, ConfiguredDeriveTrait}

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

public func templateInstantiationName(spelling: String): String {
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

func isCppIdentifierByte(value: UInt8): Bool {
    return (value >= 48u8 && value <= 57u8) ||
        (value >= 65u8 && value <= 90u8) ||
        (value >= 97u8 && value <= 122u8) || value == 95u8
}

func replaceCppIdentifier(input: String, identifier: String, replacement: String): String {
    if (identifier.isEmpty() || input.size < identifier.size) {
        return input
    }
    let result = StringBuilder()
    var index = 0
    while (index < input.size) {
        let end = index + identifier.size
        let leftBoundary = index == 0 || !isCppIdentifierByte(input[index - 1])
        let rightBoundary = end == input.size || (end < input.size && !isCppIdentifierByte(input[end]))
        if (end <= input.size && leftBoundary && rightBoundary && input[index..end] == identifier) {
            result.append(replacement)
            index = end
        } else {
            result.append(input[index..(index + 1)])
            index += 1
        }
    }
    return result.toString()
}

func mergeTemplateSemanticFlags(target: CompInfo, definition: CompInfo): Unit {
    target.packedAttr ||= definition.packedAttr
    target.hasUnevaluableBitFieldWidth ||= definition.hasUnevaluableBitFieldWidth
    target.foundUnknownAttr ||= definition.foundUnknownAttr
    target.hasOwnVirtualMethod ||= definition.hasOwnVirtualMethod
    target.hasDestructor ||= definition.hasDestructor
    target.hasUnrepresentedVirtualMethod ||= definition.hasUnrepresentedVirtualMethod
    target.forceOpaque ||= definition.forceOpaque
}

func mergeSynthesizedTemplateComp(target: CompInfo, synthesized: CompInfo): Unit {
    if (!synthesized.baseMembers.isEmpty()) {
        while (!target.baseMembers.isEmpty()) {
            target.baseMembers.remove(at: target.baseMembers.size - 1)
        }
        target.baseMembers.add(all: synthesized.baseMembers)
    }

    target.fields = match ((target.fields, synthesized.fields)) {
        case (CompFields.CompFieldsBefore(parsed), CompFields.CompFieldsBefore(concrete)) =>
            if (parsed.size != concrete.size) {
                synthesized.fields
            } else {
                let fields = ArrayList<RawField>()
                for (index in 0..parsed.size) {
                    let parsedField = parsed[index]
                    let concreteField = concrete[index]
                    let offset = match (parsedField.offset) {
                        case Some(value) => Some(value)
                        case None => concreteField.offset
                    }
                    let bitfieldWidth = match (parsedField.bitfieldWidth) {
                        case Some(value) => Some(value)
                        case None => concreteField.bitfieldWidth
                    }
                    fields.add(RawField(
                        concreteField.name,
                        concreteField.ty,
                        concreteField.comment,
                        bitfieldWidth,
                        offset,
                        isPublic: parsedField.isPublic
                    ))
                }
                CompFields.CompFieldsBefore(fields)
            }
        case (_, _) => synthesized.fields
    }

    for (inner in synthesized.innerTypes) {
        if (!target.innerTypes.contains(inner)) {
            target.innerTypes.add(inner)
        }
    }
    while (!target.templateParams.isEmpty()) {
        target.templateParams.remove(at: target.templateParams.size - 1)
    }
    while (!target.nonTypeTemplateParams.isEmpty()) {
        target.nonTypeTemplateParams.remove(at: target.nonTypeTemplateParams.size - 1)
    }
    target.hasTemplateTypeParams = false
    target.hasNonTypeTemplateParams = false
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

func deriveTraitCacheDiscriminant(deriveTrait: DeriveTrait): UInt8 {
    return match (deriveTrait) {
        case DeriveTrait.Copy => 0
        case DeriveTrait.Debug => 1
        case DeriveTrait.Default => 2
        case DeriveTrait.Hash => 3
        case DeriveTrait.PartialEqOrPartialOrd => 4
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
    public let concreteTemplateInstantiations: HashMap<ItemId, TemplateInstantiation> = HashMap()
    let materializedNestedTemplateTypes: HashMap<String, TypeId> = HashMap()
    let materializedNestedTemplateItems: ItemSet = ItemSet()

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

    public var usedTemplateParameters: ?HashMap<ItemId, ItemSet> = None
    public var haveVtable: ?HashMap<ItemId, HasVtableResult> = None
    public var sizednessResults: ?HashMap<ItemId, SizednessResult> = None
    public var haveDestructor: ?ItemSet = None
    public var cannotDeriveDebug: ?HashMap<ItemId, CanDerive> = None
    public var cannotDeriveDefault: ?HashMap<ItemId, CanDerive> = None
    public var cannotDeriveCopy: ?HashMap<ItemId, CanDerive> = None
    public var cannotDeriveHash: ?HashMap<ItemId, CanDerive> = None
    public var cannotDerivePartialEqOrPartialOrd: ?HashMap<ItemId, CanDerive> = None
    public var hasTypeParameterInArrayResults: ?ItemSet = None
    public var hasFloatResults: ?ItemSet = None
    let blocklistedTraitResults: HashMap<String, CanDerive> = HashMap()

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
        let targetItem = this.resolveItemFallible(wrapperId)
        let layout = targetItem
            .flatMap({item => item.kind.asType()})
            .flatMap({target => target.layout})
        let location = targetItem.flatMap({item => item.location})
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
        let canonicalTy = ty.canonicalType()
        if (ty != canonicalTy &&
            (ty.declaration().kind() == clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl ||
            (ty.kind() == clang.CXTypeKind_CXType_Typedef &&
            (ty.templateArgs().isSome() || ty.spelling().contains("<"))))) {
            return None
        }
        let isTemplateInstantiation = !isTemplateDefinition &&
            ty.kind() != clang.CXTypeKind_CXType_Typedef &&
            (ty.templateArgs().map({args => !args.isEmpty()}).getOrDefault({=> false}) ||
            canonicalTy.templateArgs().map({args => !args.isEmpty()}).getOrDefault({=> false}))
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
            let exactTid = this.getResolvedType(decl)
            var knownTid = exactTid
            if (knownTid.isNone()) {
                if (let Some(primary) <- decl.cursor.specialized()) {
                    knownTid = this.getResolvedType(
                        clang.CanonicalTypeDeclaration(primary.curType(), primary.canonical())
                    )
                }
            }
            if (let Some(tid) <- knownTid) {
                if (ty.spelling().contains("<") && ty.fallibleLayout(this).ok().isSome()) {
                    if (let Some(instantiation) <- this.templateInstantiationFromKnownDefinition(
                        ty,
                        tid,
                        ty.spelling(),
                        HashMap<TypeId, TypeId>()
                    )) {
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
            }
            if (let Some(tid) <- exactTid) {
                return Some(this.buildTyWrapper(withId, tid, parentId, ty))
            }
        }

        return this.buildBuiltinTy(ty)
    }

    func completeNestedTemplateInstantiation(
        instantiation: TemplateInstantiation,
        spelling: String,
        concreteCursor!: ?clang.Cursor = None
    ): TemplateInstantiation {
        let parameterKinds = this.templateInstantiationParameterKinds(
            instantiation,
            concreteCursor: concreteCursor
        )
        if (parameterKinds.isEmpty()) {
            return instantiation
        }

        let parsedSpellings = splitAllTemplateArgumentSpellings(spelling)
        if (parsedSpellings.size < parameterKinds.size) {
            return instantiation
        }
        let completedArguments = ArrayList<TypeId>()
        let completedSpellings = ArrayList<String>()
        let allSpellings = ArrayList<String>()
        let nonTypeSpellings = ArrayList<String>()
        let typePositions = ArrayList<Int64>()
        for ((index, parameterKind) in parameterKinds.iterator().enumerate()) {
            let spelling = parsedSpellings[index]
            allSpellings.add(spelling)
            if (parameterKind != clang.CXCursorKind_CXCursor_TemplateTypeParameter) {
                nonTypeSpellings.add(spelling)
                continue
            }
            let concreteType = match (this.tryEnsureFallbackTranslationUnit().flatMap {
                fallback => fallback.probeType(spelling)
            }) {
                case Some(value) => value
                case None => return instantiation
            }
            completedArguments.add(Item.fromTyOrRef(
                concreteType,
                concreteType.declaration(),
                None,
                this
            ))
            completedSpellings.add(spelling)
            typePositions.add(index)
        }
        return TemplateInstantiation(
            instantiation.definition,
            completedArguments.toArray(),
            instantiation.definitionCursor,
            if (nonTypeSpellings.isEmpty()) { None } else { Some(spelling) },
            kind: instantiation.kind,
            spelling: instantiation.spelling,
            argumentSpellings: completedSpellings.toArray(),
            allArgumentSpellings: allSpellings.toArray(),
            nonTypeArgumentSpellings: nonTypeSpellings.toArray(),
            typeArgumentPositions: typePositions.toArray()
        )
    }

    func templateInstantiationParameterKinds(
        instantiation: TemplateInstantiation,
        concreteCursor!: ?clang.Cursor = None
    ): Array<clang.CXCursorKind> {
        let owners = ArrayList<clang.Cursor>()
        let seenOwners = HashSet<String>()
        var current: ?clang.Cursor = concreteCursor
        while (let Some(cursor) <- current) {
            let owner = cursor.specialized().getOrDefault({=> cursor})
            if (owner.isTemplateLike()) {
                let identity = owner.usr().getOrDefault({=> owner.hashCode().toString()})
                if (seenOwners.add(identity)) {
                    owners.add(owner)
                }
            }
            current = cursor.fallibleSemanticParent()
        }
        if (owners.isEmpty()) {
            current = Some(instantiation.definitionCursor)
            while (let Some(cursor) <- current) {
                if (cursor.isTemplateLike()) {
                    let identity = cursor.usr().getOrDefault({=> cursor.hashCode().toString()})
                    if (seenOwners.add(identity)) {
                        owners.add(cursor)
                    }
                }
                current = cursor.fallibleSemanticParent()
            }
        }
        owners.reverse()

        let kinds = ArrayList<clang.CXCursorKind>()
        for (owner in owners) {
            owner.visit {
                child =>
                let kind = child.kind()
                if (kind == clang.CXCursorKind_CXCursor_TemplateTypeParameter ||
                    kind == clang.CXCursorKind_CXCursor_NonTypeTemplateParameter ||
                    kind == clang.CXCursorKind_CXCursor_TemplateTemplateParameter) {
                    kinds.add(kind)
                }
                return clang.CXChildVisitResult_CXChildVisit_Continue
            }
        }
        return kinds.toArray()
    }

    func buildTemplateInstantiation(
        withId: ItemId,
        rawInstantiation: TemplateInstantiation,
        parentId: ?ItemId,
        ty: clang.Type,
        location: ?clang.Cursor
    ): ?TypeId {
        let instantiation = this.completeNestedTemplateInstantiation(
            rawInstantiation,
            ty.spelling(),
            concreteCursor: Some(ty.declaration())
        )
        let definitionId = this.templateDefinitionId(instantiation)
            .getOrDefault({=> instantiation.definition})
        let definitionIdentity = instantiation.definitionCursor.usr().getOrDefault {
            => "cursor_${instantiation.definitionCursor.hashCode()}"
        }
        let key = "${definitionIdentity}|${ty.canonicalType().spelling()}"
        if (let Some(existing) <- this.templateInstantiations.get(key)) {
            // A template definition can be encountered through the concrete type
            // while its own declaration is still being parsed. It is not a
            // materialized specialization and must not own the concrete cache key.
            if (existing != instantiation.definition) {
                return Some(this.buildTyWrapper(withId, existing, parentId, ty))
            }
        }

        this.templateInstantiations.add(key, withId)
        let spelling = ty.spelling()
        let name = templateInstantiationName(spelling)
        let declaration = ty.declaration()
        let concreteDefinition = declaration.definition().getOrDefault({=> declaration})
        let hasConcreteDefinition = concreteDefinition.isDefinition() && declaration.specialized().isSome()
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
                this.resolveItemFallible(definitionId)
                    .map({item => item.parentId})
                    .getOrDefault({=> this.rootModule}),
                ItemKind.KindType(templateType),
                location.map({cursor => cursor.location()})
            ),
            None,
            location
        )

        if (hasConcreteDefinition) {
            if (let Ok(comp) <- CompInfo.fromTy(withId, ty, Some(concreteDefinition), this)) {
                if (instantiation.kind.isPrimary() || instantiation.kind.isPartialSpecialization()) {
                    if (let Some(definitionComp) <- this.templateDefinitionComp(instantiation)) {
                        mergeTemplateSemanticFlags(comp, definitionComp)
                    }
                    if (let Some(templateComp) <- this.instantiateTemplateComp(
                        instantiation,
                        ownerId: Some(withId)
                    )) {
                        mergeSynthesizedTemplateComp(comp, templateComp)
                    }
                }
                let representsConcreteDefinition = comp.hasFields() || !comp.baseMembers.isEmpty() ||
                    instantiation.kind.isExplicitSpecialization() ||
                    ty.fallibleLayout(this).ok().map({layout => layout.size <= 1}).getOrDefault({=> false})
                if (representsConcreteDefinition) {
                    this.concreteTemplateInstantiations.add(withId, instantiation)
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

    func substituteTemplateSpelling(
        source: String,
        substitutionSpellings: HashMap<TypeId, String>,
        namedSubstitutionSpellings!: HashMap<String, String> = HashMap<String, String>()
    ): String {
        var result = source
        for ((parameter, replacement) in substitutionSpellings) {
            let parameterName = parameter
                .intoResolver()
                .throughTypeRefs()
                .throughTypeAliases()
                .resolve(this)
                .kind
                .expectType()
                .name
            if (let Some(name) <- parameterName) {
                result = replaceCppIdentifier(result, name, replacement)
            }
        }
        for ((name, replacement) in namedSubstitutionSpellings) {
            result = replaceCppIdentifier(result, name, replacement)
        }
        return result
    }

    func probeConcreteTemplateType(spelling: String): ?clang.Type {
        let fallback = match (this.tryEnsureFallbackTranslationUnit()) {
            case Some(value) => value
            case None =>
                eprintln("Warning: unable to inspect concrete C++ template type '${spelling}': fallback translation unit is unavailable")
                return None
        }
        let concreteType = match (fallback.probeType(spelling)) {
            case Some(value) => value
            case None =>
                eprintln("Warning: unable to inspect concrete C++ template type '${spelling}': type probe failed")
                return None
        }
        if (concreteType.fallibleLayout(this).isErr()) {
            eprintln("Warning: unable to inspect concrete C++ template type '${spelling}': layout is unavailable")
            return None
        }
        return Some(concreteType)
    }

    func templateInstantiationFromKnownDefinition(
        ty: clang.Type,
        definition: TypeId,
        spelling: String,
        substitutions: HashMap<TypeId, TypeId>
    ): ?TemplateInstantiation {
        let directArguments = ty.templateArgs().getOrDefault({=> Array<clang.Type>()})
        let canonicalArguments = ty.canonicalType().templateArgs().getOrDefault({=> Array<clang.Type>()})
        let parsedSpellings = splitTemplateArgumentSpellings(spelling)
        let argumentCount = max(
            max(directArguments.size, canonicalArguments.size),
            parsedSpellings.size
        )
        if (argumentCount == 0) {
            return None
        }
        let arguments = ArrayList<TypeId>()
        let argumentSpellings = ArrayList<String>()
        let allArgumentSpellings = ArrayList<String>()
        let nonTypeArgumentSpellings = ArrayList<String>()
        let typeArgumentPositions = ArrayList<Int64>()
        var hasNonTypeArgument = false
        for (index in 0..argumentCount) {
            let argument: ?clang.Type = if (index < directArguments.size && directArguments[index].isValid()) {
                Some(directArguments[index])
            } else if (index < canonicalArguments.size && canonicalArguments[index].isValid()) {
                Some(canonicalArguments[index])
            } else {
                None
            }
            match (argument) {
                case Some(value) =>
                    arguments.add(Item.fromTyOrRef(
                        value,
                        value.declaration(),
                        None,
                        this
                    ))
                    argumentSpellings.add(value.spelling())
                    allArgumentSpellings.add(value.spelling())
                    typeArgumentPositions.add(index)
                case None =>
                    let value = if (index < parsedSpellings.size) {
                        parsedSpellings[index]
                    } else {
                        ""
                    }
                    let templatePrefix = value.indexOf("<")
                        .map({open => value[0..open]})
                        .getOrDefault({=> value})
                    var ownerReplacement: ?TypeId = None
                    for ((candidateDefinition, candidateOwner) in substitutions) {
                        let definitionName = candidateDefinition
                            .intoResolver()
                            .throughTypeRefs()
                            .throughTypeAliases()
                            .resolve(this)
                            .baseName(this)
                        if (templatePrefix == definitionName ||
                            templatePrefix.endsWith("::${definitionName}")) {
                            ownerReplacement = Some(candidateOwner)
                            break
                        }
                    }
                    match (ownerReplacement) {
                        case Some(concreteOwner) =>
                            arguments.add(concreteOwner)
                            argumentSpellings.add(value)
                            allArgumentSpellings.add(value)
                            typeArgumentPositions.add(index)
                        case None =>
                            let probedArgument = this.tryEnsureFallbackTranslationUnit().flatMap {
                                fallback => fallback.probeType(value)
                            }
                            match (probedArgument) {
                                case Some(concreteType) =>
                                    arguments.add(Item.fromTyOrRef(
                                        concreteType,
                                        concreteType.declaration(),
                                        None,
                                        this
                                    ))
                                    argumentSpellings.add(value)
                                    allArgumentSpellings.add(value)
                                    typeArgumentPositions.add(index)
                                case None =>
                                    hasNonTypeArgument = true
                                    allArgumentSpellings.add(value)
                                    nonTypeArgumentSpellings.add(value)
                            }
                    }
            }
        }
        let declaration = ty.declaration()
        let definitionCursor = declaration.specialized().getOrDefault {
            => declaration.canonical()
        }
        return Some(TemplateInstantiation(
            definition,
            arguments.toArray(),
            definitionCursor,
            if (hasNonTypeArgument) { Some(ty.canonicalType().spelling()) } else { None },
            spelling: Some(spelling),
            argumentSpellings: argumentSpellings.toArray(),
            allArgumentSpellings: allArgumentSpellings.toArray(),
            nonTypeArgumentSpellings: nonTypeArgumentSpellings.toArray(),
            typeArgumentPositions: typeArgumentPositions.toArray()
        ))
    }

    func buildSubstitutedTemplateInstantiation(
        source: Type,
        instantiation: TemplateInstantiation,
        arguments: Array<TypeId>,
        argumentSpellings: Array<String>,
        allArgumentSpellings: Array<String>,
        nonTypeArgumentSpellings: Array<String>,
        spelling: String
    ): TypeId {
        let definitionIdentity = instantiation.definitionCursor.usr().getOrDefault {
            => "cursor_${instantiation.definitionCursor.hashCode()}"
        }
        let key = "${definitionIdentity}|${spelling}"
        if (let Some(existing) <- this.templateInstantiations.get(key)) {
            return existing
        }

        let concreteInstantiation = TemplateInstantiation(
            instantiation.definition,
            arguments,
            instantiation.definitionCursor,
            instantiation.nonTypeIdentity,
            kind: instantiation.kind,
            spelling: Some(spelling),
            argumentSpellings: argumentSpellings,
            allArgumentSpellings: allArgumentSpellings,
            nonTypeArgumentSpellings: nonTypeArgumentSpellings,
            typeArgumentPositions: instantiation.typeArgumentPositions
        )
        let probedType = this.probeConcreteTemplateType(spelling)
        let layout = match (probedType.flatMap({value => value.fallibleLayout(this).ok()})) {
            case Some(value) => Some(value)
            case None => source.layout
        }
        let newId = this.nextItemId()
        this.templateInstantiations.add(key, newId)
        let definitionId = instantiation.definition
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(this)
            .id
        this.addItem(
            Item(
                newId,
                None,
                this.resolveItem(definitionId).parentId,
                ItemKind.KindType(Type(
                    Some(templateInstantiationName(spelling)),
                    layout,
                    TypeKind.TypeKindTemplateInstantiation(concreteInstantiation),
                    source.isConst
                )),
                None
            ),
            None,
            None
        )

        var concreteComp: ?CompInfo = None
                if (let Some(concreteType) <- probedType) {
                    let concreteDeclaration = concreteType.declaration()
                        .definition()
                        .getOrDefault({=> concreteType.declaration()})
                    if (let Ok(value) <- CompInfo.fromTy(
                        newId,
                        concreteType,
                        Some(concreteDeclaration),
                        this
                    )) {
                        if (let Some(definitionComp) <- this.templateDefinitionComp(concreteInstantiation)) {
                            mergeTemplateSemanticFlags(value, definitionComp)
                        }
                        concreteComp = Some(value)
                    }
                }
                if (concreteInstantiation.kind.isPrimary() ||
                    concreteInstantiation.kind.isPartialSpecialization()) {
                    if (let Some(synthesized) <- this.instantiateTemplateComp(
                        concreteInstantiation,
                        ownerId: Some(newId)
                    )) {
                        match (concreteComp) {
                            case Some(value) =>
                                mergeSynthesizedTemplateComp(value, synthesized)
                            case None => concreteComp = Some(synthesized)
                        }
                    }
                }
                if (let Some(comp) <- concreteComp) {
                    this.resolveItem(newId).kind = ItemKind.KindType(Type(
                        Some(templateInstantiationName(spelling)),
                        layout,
                        TypeKind.TypeKindComp(comp),
                        source.isConst
                    ))
                    this.needBitfieldAllocation.add(newId)
                    this.concreteTemplateInstantiations.add(newId, concreteInstantiation)
                } else {
                    eprintln("Warning: unable to materialize concrete C++ template type '${spelling}'; preserving its layout as opaque")
                    this.resolveItem(newId).kind = ItemKind.KindType(Type(
                        Some(templateInstantiationName(spelling)),
                        layout,
                        TypeKind.TypeKindOpaque,
                        source.isConst
                    ))
                }
        return newId
    }

    func instantiateTemplateType(
        sourceId: TypeId,
        substitutions: HashMap<TypeId, TypeId>,
        failed: Box<Bool>,
        substitutionSpellings!: HashMap<TypeId, String> = HashMap<TypeId, String>(),
        namedSubstitutionSpellings!: HashMap<String, String> = HashMap<String, String>(),
        concreteParentId!: ?ItemId = None
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
        if (let Some(name) <- source.name) {
            for ((parameter, substituted) in substitutions) {
                if (let Some(parameterType) <- this.safeResolveType(parameter)) {
                    if (parameterType.name == Some(name)) {
                        return substituted
                    }
                }
            }
        }
        let resolvedSource = this.safeResolveType(resolvedSourceId).getOrDefault({=> source})
        let sourceName = this.resolveItem(resolvedSourceId).baseName(this)
        for ((parameter, substituted) in substitutions) {
            let resolvedParameterId = parameter
                .intoResolver()
                .throughTypeRefs()
                .throughTypeAliases()
                .resolve(this)
                .id
            if (this.resolveItem(resolvedParameterId).baseName(this) == sourceName) {
                return substituted
            }
        }
        if (let TypeKind.TypeKindTypeParam <- resolvedSource.kind) {
            for ((parameter, substituted) in substitutions) {
                if (this.resolveItem(parameter).baseName(this) == sourceName) {
                    return substituted
                }
            }
        }

        let newKind: ?TypeKind = match (source.kind) {
            case TypeKind.TypeKindPointer(inner) =>
                TypeKind.TypeKindPointer(this.instantiateTemplateType(
                    inner, substitutions, failed, substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: concreteParentId))
            case TypeKind.TypeKindReference(inner) =>
                TypeKind.TypeKindReference(this.instantiateTemplateType(
                    inner, substitutions, failed, substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: concreteParentId))
            case TypeKind.TypeKindArray(inner, length) =>
                TypeKind.TypeKindArray(this.instantiateTemplateType(
                    inner, substitutions, failed, substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: concreteParentId), length)
            case TypeKind.TypeKindVector(inner, length) =>
                TypeKind.TypeKindVector(this.instantiateTemplateType(
                    inner, substitutions, failed, substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: concreteParentId), length)
            case TypeKind.TypeKindAlias(inner) =>
                TypeKind.TypeKindAlias(this.instantiateTemplateType(
                    inner, substitutions, failed, substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: concreteParentId))
            case TypeKind.TypeKindTemplateAlias(inner, parameters) =>
                TypeKind.TypeKindTemplateAlias(
                    this.instantiateTemplateType(
                        inner, substitutions, failed, substitutionSpellings: substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings,
                        concreteParentId: concreteParentId),
                    parameters
                )
            case TypeKind.TypeKindFunction(signature) =>
                let arguments = ArrayList<(?String, TypeId)>()
                for ((name, argument) in signature.argumentTypes) {
                    arguments.add((name, this.instantiateTemplateType(
                        argument, substitutions, failed, substitutionSpellings: substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings,
                        concreteParentId: concreteParentId)))
                }
                TypeKind.TypeKindFunction(FunctionSig(
                    signature.name,
                    this.instantiateTemplateType(
                        signature.returnType, substitutions, failed,
                        substitutionSpellings: substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings,
                        concreteParentId: concreteParentId),
                    arguments.toArray(),
                    signature.isVariadicFunction(),
                    signature.abi,
                    valueAbiUnsupported: signature.valueAbiUnsupported
                ))
            case TypeKind.TypeKindTemplateInstantiation(instantiation) =>
                let concreteArguments = ArrayList<TypeId>()
                let concreteArgumentSpellings = ArrayList<String>()
                for ((index, argument) in instantiation.arguments.iterator().enumerate()) {
                    let concreteArgument = this.instantiateTemplateType(
                        argument,
                        substitutions,
                        failed,
                        substitutionSpellings: substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings,
                        concreteParentId: concreteParentId
                    )
                    concreteArguments.add(concreteArgument)
                    let sourceSpelling = if (index < instantiation.argumentSpellings.size) {
                        instantiation.argumentSpellings[index]
                    } else {
                        this.resolveType(argument).name.getOrDefault({=> ""})
                    }
                    let concreteArgumentSpelling = this.substituteTemplateSpelling(
                        sourceSpelling,
                        substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings
                    )
                    if (concreteArgumentSpelling.isEmpty()) {
                        failed.value = true
                        return sourceId
                    }
                    concreteArgumentSpellings.add(concreteArgumentSpelling)
                }
                let concreteAllArgumentSpellings = ArrayList<String>()
                let sourceAllArgumentSpellings = if (instantiation.allArgumentSpellings.isEmpty()) {
                    instantiation.argumentSpellings
                } else {
                    instantiation.allArgumentSpellings
                }
                for (sourceSpelling in sourceAllArgumentSpellings) {
                    let concreteSpellingPart = this.substituteTemplateSpelling(
                        sourceSpelling,
                        substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings
                    )
                    if (concreteSpellingPart.isEmpty()) {
                        failed.value = true
                        return sourceId
                    }
                    concreteAllArgumentSpellings.add(concreteSpellingPart)
                }
                let concreteNonTypeArgumentSpellings = ArrayList<String>()
                for (sourceSpelling in instantiation.nonTypeArgumentSpellings) {
                    concreteNonTypeArgumentSpellings.add(this.substituteTemplateSpelling(
                        sourceSpelling,
                        substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings
                    ))
                }
                let templatePrefix = instantiation.spelling
                    .flatMap {
                        value => value.indexOf("<").map({index => value[0..index]})
                    }
                    .getOrDefault({=> instantiation.definitionCursor.spelling()})
                let joinedArgumentSpellings = String.join(
                    concreteAllArgumentSpellings.toArray(), delimiter: ", ")
                let concreteSpelling = "${templatePrefix}<${joinedArgumentSpellings}>"
                return this.buildSubstitutedTemplateInstantiation(
                    source,
                    instantiation,
                    concreteArguments.toArray(),
                    concreteArgumentSpellings.toArray(),
                    concreteAllArgumentSpellings.toArray(),
                    concreteNonTypeArgumentSpellings.toArray(),
                    concreteSpelling
                )
            case TypeKind.TypeKindComp(comp) =>
                if (!comp.templateParams.isEmpty() || comp.hasTemplateTypeParams ||
                    comp.hasNonTypeTemplateParams) {
                    failed.value = true
                }
                return sourceId
            case TypeKind.UnresolvedTypeRef(ty, location, parentId) =>
                let resolved = match (Item.fromTy(ty, location, parentId, this)) {
                    case Ok(value) => value
                    case Err(_) =>
                        failed.value = true
                        return sourceId
                }
                return this.instantiateTemplateType(
                    resolved,
                    substitutions,
                    failed,
                    substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: concreteParentId
                )
            case TypeKind.ResolvedTypeRef(inner) =>
                if (let Some(spelling) <- source.name) {
                    if (spelling.contains("<")) {
                    let concreteSpelling = this.substituteTemplateSpelling(
                        spelling,
                        substitutionSpellings,
                        namedSubstitutionSpellings: namedSubstitutionSpellings
                    )
                    if (let Some(concreteType) <- this.probeConcreteTemplateType(concreteSpelling)) {
                        let knownDefinition = inner
                            .intoResolver()
                            .throughTypeRefs()
                            .throughTypeAliases()
                            .resolve(this)
                            .id
                        let parsedInstantiation = match (TemplateInstantiation.fromTy(concreteType, this)) {
                            case Some(value) => Some(value)
                            case None => this.templateInstantiationFromKnownDefinition(
                                concreteType,
                                knownDefinition,
                                concreteSpelling,
                                substitutions
                            )
                        }
                        if (let Some(parsed) <- parsedInstantiation) {
                        let concreteArguments = ArrayList<TypeId>()
                        for (argument in parsed.arguments) {
                            let replacement = this.templateInstantiationFor(argument).flatMap {
                                nested =>
                                if (let Some(value) <- substitutions.get(nested.definition)) {
                                    return Some(value)
                                }
                                let definition = nested.definition
                                    .intoResolver()
                                    .throughTypeRefs()
                                    .throughTypeAliases()
                                    .resolve(this)
                                    .id
                                if (let Some(value) <- substitutions.get(definition)) {
                                    return Some(value)
                                }
                                substitutions.get(canonicalItemId(this, definition))
                            }
                            concreteArguments.add(replacement.getOrDefault({=> argument}))
                        }
                        let concreteInstantiation = TemplateInstantiation(
                            parsed.definition,
                            concreteArguments.toArray(),
                            parsed.definitionCursor,
                            parsed.nonTypeIdentity,
                            kind: parsed.kind,
                            spelling: Some(concreteSpelling),
                            argumentSpellings: parsed.argumentSpellings,
                            allArgumentSpellings: parsed.allArgumentSpellings,
                            nonTypeArgumentSpellings: parsed.nonTypeArgumentSpellings,
                            typeArgumentPositions: parsed.typeArgumentPositions
                        )
                        let newId = this.nextItemId()
                        if (let Some(concrete) <- this.buildTemplateInstantiation(
                            newId,
                            concreteInstantiation,
                            None,
                            concreteType,
                            Some(concreteType.declaration())
                        )) {
                            return concrete
                        }
                            }
                        }
                    }
                }
                return this.instantiateTemplateType(
                    inner, substitutions, failed, substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: concreteParentId)
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
                concreteParentId.getOrDefault({=> this.rootModule}),
                ItemKind.KindType(Type(source.name, instantiatedLayout, instantiatedKind, source.isConst)),
                None
            ),
            None,
            None
        )
        substitutions.add(sourceId, newId)
        return newId
    }

    func instantiateNestedTemplateType(
        sourceId: TypeId,
        ownerId: ItemId,
        ownerSpelling: String,
        substitutions: HashMap<TypeId, TypeId>,
        substitutionSpellings: HashMap<TypeId, String>,
        namedSubstitutionSpellings: HashMap<String, String>,
        failedSubstitution: Box<Bool>
    ): ?TypeId {
        if (let Some(existing) <- substitutions.get(sourceId)) {
            return Some(existing)
        }
        let sourceItem = match (this.resolveItemFallible(sourceId)) {
            case Some(value) => value
            case None => return None
        }
        let sourceType = match (sourceItem.kind.asType()) {
            case Some(value) => value
            case None => return None
        }
        let sourceComp = match (sourceType.kind) {
            case TypeKind.TypeKindComp(value) => value
            case _ => return None
        }
        for (parameter in sourceComp.templateParams) {
            let canonical = canonicalItemId(this, parameter)
            if (!substitutions.contains(parameter) && !substitutions.contains(canonical)) {
                return None
            }
        }
        if (sourceComp.hasNonTypeTemplateParams) {
            return None
        }

        let key = "${ownerId}|${sourceId}"
        if (let Some(existing) <- this.materializedNestedTemplateTypes.get(key)) {
            substitutions.add(sourceId, existing)
            return Some(existing)
        }

        let sourceNestedName = sourceType.name.getOrDefault({=> sourceItem.baseName(this)})
        let nestedSpelling = "${ownerSpelling}::${sourceNestedName}"
        let nestedName = templateInstantiationName(nestedSpelling)
        let newId = this.nextItemId()
        this.materializedNestedTemplateTypes.add(key, newId)
        this.materializedNestedTemplateItems.add(newId)
        substitutions.add(sourceId, newId)
        this.addItem(
            Item(
                newId,
                sourceItem.comment,
                ownerId,
                ItemKind.KindType(Type(
                    Some(nestedName),
                    None,
                    TypeKind.TypeKindOpaque,
                    sourceType.isConst
                )),
                sourceItem.location
            ),
            None,
            None
        )

        let concreteType = this.probeConcreteTemplateType(nestedSpelling)
        let exactLayout = concreteType.flatMap({value => value.fallibleLayout(this).ok()})

        let synthesized = this.instantiateCompWithSubstitutions(
            sourceComp,
            newId,
            nestedSpelling,
            substitutions,
            substitutionSpellings,
            namedSubstitutionSpellings,
            failedSubstitution
        )
        if (failedSubstitution.value || exactLayout.isNone()) {
            if (exactLayout.isNone()) {
                eprintln(
                    "Warning: unable to obtain the exact C++ layout for nested template type '${nestedSpelling}'; preserving it as opaque")
            } else {
                eprintln(
                    "Warning: unable to substitute every field of nested template type '${nestedSpelling}'; preserving its exact layout as opaque")
            }
            this.resolveItem(newId).kind = ItemKind.KindType(Type(
                Some(nestedName),
                exactLayout,
                TypeKind.TypeKindOpaque,
                sourceType.isConst
            ))
            return Some(newId)
        }
        let concrete = match (concreteType) {
            case Some(value) =>
                let declaration = value.declaration().definition().getOrDefault {
                    => value.declaration()
                }
                match (CompInfo.fromTy(newId, value, Some(declaration), this)) {
                    case Ok(parsed) =>
                        mergeSynthesizedTemplateComp(parsed, synthesized)
                        parsed
                    case Err(_) => synthesized
                }
            case None => synthesized
        }
        this.resolveItem(newId).kind = ItemKind.KindType(Type(
            Some(nestedName),
            exactLayout,
            TypeKind.TypeKindComp(concrete),
            sourceType.isConst
        ))
        this.needBitfieldAllocation.add(newId)
        return Some(newId)
    }

    func instantiateCompWithSubstitutions(
        definitionComp: CompInfo,
        ownerId: ItemId,
        ownerSpelling: String,
        substitutions: HashMap<TypeId, TypeId>,
        substitutionSpellings: HashMap<TypeId, String>,
        namedSubstitutionSpellings: HashMap<String, String>,
        failedSubstitution: Box<Bool>
    ): CompInfo {
        let concrete = CompInfo(definitionComp.kind, isCxxRecord: definitionComp.isCxxRecord)
        concrete.isForwardDeclaration = false
        mergeTemplateSemanticFlags(concrete, definitionComp)

        for (inner in definitionComp.innerTypes) {
            if (let Some(materialized) <- this.instantiateNestedTemplateType(
                inner,
                ownerId,
                ownerSpelling,
                substitutions,
                substitutionSpellings,
                namedSubstitutionSpellings,
                failedSubstitution
            )) {
                concrete.innerTypes.add(materialized)
            }
        }

        let rawFields = match (definitionComp.fields) {
            case CompFields.CompFieldsBefore(value) => value
            case _ =>
                failedSubstitution.value = true
                return concrete
        }
        let concreteFields = ArrayList<RawField>()
        for (field in rawFields) {
            concreteFields.add(RawField(
                field.name,
                this.instantiateTemplateType(
                    field.ty,
                    substitutions,
                    failedSubstitution,
                    substitutionSpellings: substitutionSpellings,
                    namedSubstitutionSpellings: namedSubstitutionSpellings,
                    concreteParentId: Some(ownerId)
                ),
                field.comment,
                field.bitfieldWidth,
                field.offset,
                isPublic: field.isPublic
            ))
        }
        concrete.fields = CompFields.CompFieldsBefore(concreteFields)

        for (base in definitionComp.baseMembers) {
            let concreteBase = this.instantiateTemplateType(
                base.ty,
                substitutions,
                failedSubstitution,
                substitutionSpellings: substitutionSpellings,
                namedSubstitutionSpellings: namedSubstitutionSpellings,
                concreteParentId: Some(ownerId)
            )
            concrete.baseMembers.add(Base(
                concreteBase,
                base.kind,
                base.fieldName,
                base.isPublic
            ))
        }
        return concrete
    }

    func instantiateTemplateComp(
        instantiation: TemplateInstantiation,
        ownerId!: ?ItemId = None
    ): ?CompInfo {
        let definitionComp = match (this.templateDefinitionComp(instantiation)) {
            case Some(value) => value
            case None => return None
        }
        this.populateTemplateDefinitionInnerTypes(instantiation, definitionComp)
        let definitionId = instantiation.definition
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(this)
            .id
        let templateParameters = this.templateInstantiationParameters(
            instantiation,
            definitionId
        )
        if (templateParameters.size > instantiation.arguments.size) {
            return None
        }

        let substitutions = HashMap<TypeId, TypeId>()
        let substitutionSpellings = HashMap<TypeId, String>()
        let namedSubstitutionSpellings = HashMap<String, String>()
        if (let Some(concreteOwner) <- ownerId) {
            substitutions.add(instantiation.definition, concreteOwner)
            substitutions.add(definitionId, concreteOwner)
            let canonicalDefinition = canonicalItemId(this, definitionId)
            substitutions.add(canonicalDefinition, concreteOwner)
        }
        for ((index, parameter) in templateParameters.iterator().enumerate()) {
            substitutions.add(parameter, instantiation.arguments[index])
            let canonical = canonicalItemId(this, parameter)
            if (!substitutions.contains(canonical)) {
                substitutions.add(canonical, instantiation.arguments[index])
            }
            if (index < instantiation.argumentSpellings.size) {
                substitutionSpellings.add(parameter, instantiation.argumentSpellings[index])
                if (!substitutionSpellings.contains(canonical)) {
                    substitutionSpellings.add(canonical, instantiation.argumentSpellings[index])
                }
            }
        }
        for ((index, parameterName) in definitionComp.nonTypeTemplateParams.iterator().enumerate()) {
            if (index < instantiation.nonTypeArgumentSpellings.size) {
                namedSubstitutionSpellings.add(
                    parameterName,
                    instantiation.nonTypeArgumentSpellings[index]
                )
            }
        }

        let failedSubstitution = Box(false)
        let concreteOwner = ownerId.getOrDefault({=> instantiation.definition})
        let concreteSpelling = instantiation.spelling.getOrDefault {
            => instantiation.definitionCursor.spelling()
        }
        let concrete = this.instantiateCompWithSubstitutions(
            definitionComp,
            concreteOwner,
            concreteSpelling,
            substitutions,
            substitutionSpellings,
            namedSubstitutionSpellings,
            failedSubstitution
        )
        if (failedSubstitution.value) {
            return None
        }
        return Some(concrete)
    }

    func populateTemplateDefinitionInnerTypes(
        instantiation: TemplateInstantiation,
        definitionComp: CompInfo
    ): Unit {
        let definitionId = instantiation.definition
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(this)
            .id
        let seen = ItemSet()
        for (inner in definitionComp.innerTypes) {
            seen.add(inner)
        }
        let cursor = instantiation.definitionCursor.definition().getOrDefault {
            => instantiation.definitionCursor
        }
        cursor.visit {
            child =>
            let kind = child.kind()
            let isInnerType = kind == clang.CXCursorKind_CXCursor_EnumDecl ||
                kind == clang.CXCursorKind_CXCursor_TypedefDecl ||
                kind == clang.CXCursorKind_CXCursor_TypeAliasDecl ||
                kind == clang.CXCursorKind_CXCursor_TypeAliasTemplateDecl ||
                kind == clang.CXCursorKind_CXCursor_StructDecl ||
                kind == clang.CXCursorKind_CXCursor_UnionDecl ||
                kind == clang.CXCursorKind_CXCursor_ClassDecl ||
                kind == clang.CXCursorKind_CXCursor_ClassTemplate
            if (!isInnerType) {
                return clang.CXChildVisitResult_CXChildVisit_Continue
            }
            if (let Ok(inner) <- Item.parse(child, Some(definitionId), this)) {
                if (seen.add(inner)) {
                    definitionComp.innerTypes.add(inner)
                }
            }
            return clang.CXChildVisitResult_CXChildVisit_Continue
        }
    }

    func templateDefinitionId(instantiation: TemplateInstantiation): ?TypeId {
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
        return Some(latestDefinition
            .intoResolver()
            .throughTypeRefs()
            .throughTypeAliases()
            .resolve(this).id)
    }

    func normalizeTemplateInstantiationDefinition(
        instantiation: TemplateInstantiation
    ): TemplateInstantiation {
        let definition = match (this.templateDefinitionId(instantiation)) {
            case Some(value) => value
            case None => return instantiation
        }
        if (definition == instantiation.definition) {
            return instantiation
        }
        return TemplateInstantiation(
            definition,
            instantiation.arguments,
            instantiation.definitionCursor,
            instantiation.nonTypeIdentity,
            kind: instantiation.kind,
            spelling: instantiation.spelling,
            argumentSpellings: instantiation.argumentSpellings,
            allArgumentSpellings: instantiation.allArgumentSpellings,
            nonTypeArgumentSpellings: instantiation.nonTypeArgumentSpellings,
            typeArgumentPositions: instantiation.typeArgumentPositions
        )
    }

    func templateInstantiationParameters(
        instantiation: TemplateInstantiation,
        definitionId: TypeId
    ): Array<TypeId> {
        let owners = ArrayList<clang.Cursor>()
        var current: ?clang.Cursor = Some(instantiation.definitionCursor)
        while (let Some(cursor) <- current) {
            if (cursor.isTemplateLike()) {
                owners.add(cursor)
            }
            current = cursor.fallibleSemanticParent()
        }
        owners.reverse()

        let parameters = ArrayList<TypeId>()
        let seen = HashSet<TypeId>()
        for (owner in owners) {
            let definition = owner.definition().getOrDefault({=> owner})
            var ownerId = this.typeDeclarations.get(definition)
            if (ownerId.isNone()) {
                ownerId = this.getResolvedType(clang.CanonicalTypeDeclaration(
                    owner.curType(),
                    owner.canonical()
                ))
            }
            if (let Some(id) <- ownerId) {
                for (parameter in selfTemplateParams(id, this)) {
                    if (seen.add(parameter)) {
                        parameters.add(parameter)
                    }
                }
            }
        }
        for (parameter in allTemplateParams(definitionId, this)) {
            if (seen.add(parameter)) {
                parameters.add(parameter)
            }
        }
        return parameters.toArray()
    }

    func templateDefinitionComp(instantiation: TemplateInstantiation): ?CompInfo {
        let definitionId = match (this.templateDefinitionId(instantiation)) {
            case Some(value) => value
            case None => return None
        }
        let definitionItem = this.resolveItem(definitionId)
        let definitionType = match (definitionItem.kind.asType()) {
            case Some(value) => value
            case None => return None
        }
        let definitionComp = match (definitionType.kind) {
            case TypeKind.TypeKindComp(value) => value
            case _ => return None
        }
        return Some(definitionComp)
    }

    func populateTemplateInstantiations(): Unit {
        let concrete = ArrayList<(ItemId, TemplateInstantiation)>()
        for ((id, instantiation) in this.concreteTemplateInstantiations) {
            concrete.add((id, instantiation))
        }
        for ((id, instantiation) in concrete) {
            this.concreteTemplateInstantiations.add(
                id,
                this.normalizeTemplateInstantiationDefinition(instantiation)
            )
        }

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
            let rawInstantiation = match (ty.kind) {
                case TypeKind.TypeKindTemplateInstantiation(value) => value
                case _ => continue
            }
            let normalizedInstantiation = this.normalizeTemplateInstantiationDefinition(rawInstantiation)
            let instantiation = this.completeNestedTemplateInstantiation(
                normalizedInstantiation,
                rawInstantiation.spelling.getOrDefault({=> rawInstantiation.definitionCursor.spelling()})
            )
            this.concreteTemplateInstantiations.add(id, instantiation)
            if (let Some(comp) <- this.instantiateTemplateComp(instantiation, ownerId: Some(id))) {
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

    public func templateInstantiationFor(id: ItemId): ?TemplateInstantiation {
        if (let Some(instantiation) <- this.concreteTemplateInstantiations.get(id)) {
            return Some(instantiation)
        }
        let ty = match (this.safeResolveType(id)) {
            case Some(value) => value
            case None => return None
        }
        return match (ty.kind) {
            case TypeKind.TypeKindTemplateInstantiation(instantiation) => Some(instantiation)
            case _ => None
        }
    }

    public func isMaterializedNestedTemplateType(id: ItemId): Bool {
        return this.materializedNestedTemplateItems.contains(id)
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
        if (item.kind.isType() &&
            (item.annotations.hide() || item.policyNameTarget(this).annotations.hide())) {
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
        if (item.annotations.opaque() || item.policyNameTarget(this).annotations.opaque()) {
            return true
        }
        if (this.options.opaqueTypes.matches(this.itemPolicyName(item))) {
            return true
        }
        let instantiation = match (this.templateInstantiationFor(item.id)) {
            case Some(value) => value
            case None => return false
        }
        if (let Some(spelling) <- instantiation.spelling) {
            if (this.options.opaqueTypes.matches(spelling)) {
                return true
            }
        }
        let definitionName = this.itemPolicyName(this.resolveItem(instantiation.definition))
        let argumentNames = if (!instantiation.allArgumentSpellings.isEmpty()) {
            instantiation.allArgumentSpellings
        } else {
            Array<String>(instantiation.arguments.size) {
                index => this.itemPolicyName(this.resolveItem(instantiation.arguments[index]))
            }
        }
        let instantiatedName = "${definitionName}<${String.join(argumentNames, delimiter: ", ")}>"
        return this.options.opaqueTypes.matches(instantiatedName)
    }

    public func noDeriveByName(item: Item, deriveTrait: DeriveTrait): Bool {
        let name = this.itemPolicyName(item)
        return match (deriveTrait) {
            case DeriveTrait.Copy => this.options.noCopyTypes.matches(name)
            case DeriveTrait.Debug => this.options.noDebugTypes.matches(name)
            case DeriveTrait.Default => this.options.noDefaultTypes.matches(name)
            case DeriveTrait.Hash => this.options.noHashTypes.matches(name)
            case DeriveTrait.PartialEqOrPartialOrd => this.options.noPartialEqTypes.matches(name)
        }
    }

    func configuredDeriveTrait(deriveTrait: DeriveTrait): ConfiguredDeriveTrait {
        return match (deriveTrait) {
            case DeriveTrait.Copy => ConfiguredDeriveTrait.Copy
            case DeriveTrait.Debug => ConfiguredDeriveTrait.Debug
            case DeriveTrait.Default => ConfiguredDeriveTrait.Default
            case DeriveTrait.Hash => ConfiguredDeriveTrait.Hash
            case DeriveTrait.PartialEqOrPartialOrd => ConfiguredDeriveTrait.PartialEqOrPartialOrd
        }
    }

    func configuredCanDerive(result: ConfiguredCanDerive): CanDerive {
        return match (result) {
            case ConfiguredCanDerive.Yes => CanDerive.Yes
            case ConfiguredCanDerive.Manually => CanDerive.Manually
            case ConfiguredCanDerive.No => CanDerive.No
        }
    }

    public func blocklistedTypeImplementsTrait(item: Item, deriveTrait: DeriveTrait): CanDerive {
        let cacheKey = "${item.id}:${deriveTraitCacheDiscriminant(deriveTrait)}"
        if (let Some(cached) <- this.blocklistedTraitResults.get(cacheKey)) {
            return cached
        }
        let ty = match (item.asType()) {
            case Some(value) => value
            case None =>
                this.blocklistedTraitResults.add(cacheKey, CanDerive.No)
                return CanDerive.No
        }
        let name = match (ty.name) {
            case Some(value) => value
            case None =>
                this.blocklistedTraitResults.add(cacheKey, CanDerive.No)
                return CanDerive.No
        }
        var result = CanDerive.No
        if (let Some(callback) <- this.options.blocklistedTypeImplementsTraitCallback) {
            if (let Some(configuredResult) <- callback(name, this.configuredDeriveTrait(deriveTrait))) {
                let configured = this.configuredCanDerive(configuredResult)
                this.blocklistedTraitResults.add(cacheKey, configured)
                return configured
            }
        } else if (this.isStdintType(name)) {
            result = CanDerive.Yes
        }
        this.blocklistedTraitResults.add(cacheKey, result)
        return result
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
        let seen = ItemSet()
        let used = match (this.usedTemplateParameters) {
            case Some(results) => results.get(id).getOrDefault({=> ItemSet()})
            case None => throw Exception("template parameter usage analysis has not been computed")
        }
        for (parameter in allTemplateParams(id, this)) {
            let canonical = canonicalItemId(this, parameter)
            if (used.contains(canonical) && seen.add(canonical)) {
                result.add(parameter)
            }
        }
        return result.toArray()
    }

    public func publicTemplateInstantiationSpelling(instantiation: TemplateInstantiation): String {
        return this.publicTemplateInstantiationSpellingInner(instantiation, ItemSet())
    }

    func publicTemplateInstantiationSpellingInner(
        instantiation: TemplateInstantiation,
        visiting: ItemSet
    ): String {
        let sourceSpelling = instantiation.spelling.getOrDefault {
            => instantiation.definitionCursor.spelling()
        }
        if (!instantiation.kind.isPrimary()) {
            return sourceSpelling
        }
        let firstTemplateOpen = sourceSpelling.indexOf("<")
        let firstScope = sourceSpelling.indexOf("::")
        if (let Some(open) <- firstTemplateOpen) {
            if (let Some(scope) <- firstScope) {
                if (open < scope) {
                    return sourceSpelling
                }
            }
        }
        let prefix = sourceSpelling.indexOf("<")
            .map({index => sourceSpelling[0..index]})
            .getOrDefault({=> sourceSpelling})
        let allSpellings = if (!instantiation.allArgumentSpellings.isEmpty()) {
            instantiation.allArgumentSpellings
        } else {
            instantiation.argumentSpellings
        }
        if (allSpellings.isEmpty()) {
            return prefix
        }

        let typePositions = if (!instantiation.typeArgumentPositions.isEmpty()) {
            instantiation.typeArgumentPositions
        } else {
            Array<Int64>(instantiation.arguments.size) {index => index}
        }
        let parameters = selfTemplateParams(instantiation.definition, this)
        let selected = ArrayList<String>()
        var typeArgumentIndex = 0
        for ((position, spelling) in allSpellings.iterator().enumerate()) {
            let isTypeArgument = typeArgumentIndex < typePositions.size &&
                typePositions[typeArgumentIndex] == position
            if (!isTypeArgument) {
                selected.add(spelling)
                continue
            }
            if (typeArgumentIndex >= parameters.size ||
                this.usesTemplateParameter(instantiation.definition, parameters[typeArgumentIndex])) {
                let argumentSpelling = if (typeArgumentIndex < instantiation.arguments.size) {
                    let argument = instantiation.arguments[typeArgumentIndex]
                        .intoResolver()
                        .throughTypeRefs()
                        .throughTypeAliases()
                        .resolve(this)
                        .id
                    if (!visiting.contains(argument)) {
                        match (this.templateInstantiationFor(argument)) {
                            case Some(nested) =>
                                visiting.add(argument)
                                let nestedSpelling = this.publicTemplateInstantiationSpellingInner(
                                    nested,
                                    visiting
                                )
                                visiting.remove(argument)
                                nestedSpelling
                            case None => spelling
                        }
                    } else {
                        spelling
                    }
                } else {
                    spelling
                }
                selected.add(argumentSpelling)
            }
            typeArgumentIndex += 1
        }
        if (selected.isEmpty()) {
            return prefix
        }
        return "${prefix}<${String.join(selected.toArray(), delimiter: ", ")}>"
    }

    public func usesAnyTemplateParameters(id: ItemId): Bool {
        if (this.isBlocklistedItem(id)) {
            return !allTemplateParams(id, this).isEmpty()
        }
        return match (this.usedTemplateParameters) {
            case Some(results) => results.get(id).map({parameters => !parameters.isEmpty()}).getOrDefault({=> false})
            case None => throw Exception("template parameter usage analysis has not been computed")
        }
    }

    public func vtableResult(id: ItemId): HasVtableResult {
        return match (this.haveVtable) {
            case Some(results) => results.get(id).getOrDefault({=> HasVtableResult.No})
            case None => throw Exception("vtable analysis has not been computed")
        }
    }

    public func hasVtable(id: ItemId): Bool {
        return this.vtableResult(id) != HasVtableResult.No
    }

    public func hasVtablePointer(id: ItemId): Bool {
        return this.vtableResult(id) == HasVtableResult.SelfHasVtable
    }

    public func sizedness(id: TypeId): SizednessResult {
        return match (this.sizednessResults) {
            case Some(results) => results.get(id).getOrDefault({=> SizednessResult.ZeroSized})
            case None => throw Exception("sizedness analysis has not been computed")
        }
    }

    public func isZeroSized(id: TypeId): Bool {
        return this.sizedness(id) == SizednessResult.ZeroSized
    }

    public func hasDestructor(id: ItemId): Bool {
        return match (this.haveDestructor) {
            case Some(results) => results.contains(id)
            case None => throw Exception("destructor analysis has not been computed")
        }
    }

    public func hasTypeParameterInArray(id: ItemId): Bool {
        return match (this.hasTypeParameterInArrayResults) {
            case Some(results) => results.contains(id)
            case None => throw Exception("array type parameter analysis has not been computed")
        }
    }

    public func hasFloat(id: ItemId): Bool {
        return match (this.hasFloatResults) {
            case Some(results) => results.contains(id)
            case None => throw Exception("floating-point analysis has not been computed")
        }
    }

    public func canDerive(id: ItemId, deriveTrait: DeriveTrait): CanDerive {
        let results = match (deriveTrait) {
            case DeriveTrait.Debug => this.cannotDeriveDebug
            case DeriveTrait.Default => this.cannotDeriveDefault
            case DeriveTrait.Copy => this.cannotDeriveCopy
            case DeriveTrait.Hash => this.cannotDeriveHash
            case DeriveTrait.PartialEqOrPartialOrd => this.cannotDerivePartialEqOrPartialOrd
        }
        let result = match (results) {
            case Some(values) => values.get(id).getOrDefault({=> CanDerive.Yes})
            case None => throw Exception("derive analysis has not been computed")
        }
        if (deriveTrait == DeriveTrait.Copy && this.hasTypeParameterInArray(id)) {
            return CanDerive.No
        }
        return result
    }

    public func canDeriveEq(id: ItemId): Bool {
        return this.options.deriveEq &&
            this.canDerive(id, DeriveTrait.PartialEqOrPartialOrd) == CanDerive.Yes &&
            !this.hasFloat(id)
    }

    public func canDerivePartialEq(id: ItemId): Bool {
        return this.options.derivePartialEq &&
            this.canDerive(id, DeriveTrait.PartialEqOrPartialOrd) == CanDerive.Yes
    }

    public func canDerivePartialOrd(id: ItemId): Bool {
        return this.options.derivePartialOrd &&
            this.canDerive(id, DeriveTrait.PartialEqOrPartialOrd) == CanDerive.Yes
    }

    public func canDeriveOrd(id: ItemId): Bool {
        return this.options.deriveOrd &&
            this.canDerive(id, DeriveTrait.PartialEqOrPartialOrd) == CanDerive.Yes &&
            !this.hasFloat(id)
    }

    func computeCoreAnalyses(): Unit {
        let items = this.allowlistedItems.getOrThrow()
        this.haveVtable = Some(computeHasVtable(this, items))
        this.sizednessResults = Some(computeSizedness(this, items, this.haveVtable.getOrThrow()))
        this.haveDestructor = Some(analyzeHasDestructor(this, items))
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
                    parameters.add(canonicalItemId(this, parameter))
                }
                usage.add(id, parameters)
            }
            return usage
        }
    }

    func computeDeriveAnalyses(): Unit {
        let items = this.allowlistedItems.getOrThrow()
        if (this.options.deriveDebug) {
            this.cannotDeriveDebug = Some(analyzeCanDerive(this, items, DeriveTrait.Debug))
        }
        if (this.options.deriveDefault) {
            this.cannotDeriveDefault = Some(analyzeCanDerive(this, items, DeriveTrait.Default))
        }
        this.cannotDeriveCopy = Some(analyzeCanDerive(this, items, DeriveTrait.Copy))
        this.hasTypeParameterInArrayResults = Some(analyzeHasTypeParameterInArray(this, items))
        if (this.options.deriveEq || this.options.deriveOrd) {
            this.hasFloatResults = Some(analyzeHasFloat(this, items))
        }
        if (this.options.deriveHash) {
            this.cannotDeriveHash = Some(analyzeCanDerive(this, items, DeriveTrait.Hash))
        }
        if (this.options.derivePartialEq || this.options.derivePartialOrd || this.options.deriveEq) {
            this.cannotDerivePartialEqOrPartialOrd = Some(
                analyzeCanDerive(this, items, DeriveTrait.PartialEqOrPartialOrd)
            )
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
        this.populateTemplateInstantiations()
        this.computeBitfieldUnits()
        this.assignFieldNames()

        this.computeCodegenItems()

        this.computeCoreAnalyses()

        this.computeEnumTypedefCombos()

        this.computeDeriveAnalyses()

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
