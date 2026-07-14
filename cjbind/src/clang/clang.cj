package cjbind.clang

import std.fs.{File as FSFile, remove}
import std.collection.{HashMap, ArrayList}
import std.convert.*

import cjbind.result.Result

func cxstringToString(x: CXString): String {
    if (x.data.isNull()) {
        return ""
    }

    unsafe {
        let strPtr = clang_getCString(x)
        let str = strPtr.toString()

        clang_disposeString(x)
        return str
    }
}

// Converts a CXString owned by another libclang container. The container is
// responsible for releasing the string storage.
func cxstringToBorrowedString(x: CXString): String {
    if (x.data.isNull()) {
        return ""
    }

    unsafe {
        return clang_getCString(x).toString()
    }
}

public func getClangVersion(): String {
    unsafe {
        cxstringToString(clang_getClangVersion())
    }
}

public const MINIMUM_SUPPORTED_CLANG_MAJOR: Int64 = 17

func parseClangMajorVersion(version: String): ?Int64 {
    let markerParts = version.split("version ", 2)
    if (markerParts.size != 2) {
        return None
    }

    let versionParts = markerParts[1].split(".", 2)
    if (versionParts.isEmpty()) {
        return None
    }

    try {
        return Some(Int64.parse(versionParts[0]))
    } catch (_: IllegalArgumentException) {
        return None
    }
}

func validateClangVersion(version: String): Unit {
    match (parseClangMajorVersion(version)) {
        case Some(major) =>
            if (major < MINIMUM_SUPPORTED_CLANG_MAJOR) {
                throw UnsupportedException(
                    "Unsupported libclang version '${version}'. " +
                    "cjbind requires libclang ${MINIMUM_SUPPORTED_CLANG_MAJOR} or newer."
                )
            }
        case None =>
            throw UnsupportedException(
                "Unable to determine libclang version from '${version}'. " +
                "cjbind requires libclang ${MINIMUM_SUPPORTED_CLANG_MAJOR} or newer."
            )
    }
}

@When[libclang_linkage == "dynamic"]
public func ensureSupportedClangVersion(): Unit {
    validateClangVersion(getClangVersion())
}

@When[libclang_linkage == "static"]
public func ensureSupportedClangVersion(): Unit {}

// workaround cfunc capture limit
// thus we can only work as single thread
var CursorVisitCallback: HashMap<Int64, ?(Cursor) -> CXChildVisitResult> = HashMap<Int64, ?(Cursor) -> CXChildVisitResult>()
var CurrentCallbackId = 0

func getNextCallbackId(): Int64 {
    let id = CurrentCallbackId
    CurrentCallbackId += 1
    return id
}

public class Cursor <: ToString & Hashable & Equatable<Cursor> {
    let x: CXCursor

    init(x: CXCursor) {
        this.x = x
    }

    /// Get the Unified Symbol Resolution for this cursor's referent, if
    /// available.
    ///
    /// The USR can be used to compare entities across translation units.
    public func usr(): Option<String> {
        unsafe {
            let s = cxstringToString(clang_getCursorUSR(x))
            if (s.isEmpty()) {
                return None
            } else {
                return Some(s)
            }
        }
    }

    public func isDeclaration(): Bool {
        unsafe {
            return clang_isDeclaration(clang_getCursorKind(x)) != 0
        }
    }

    public func isAnonymous(): Bool {
        unsafe {
            return clang_Cursor_isAnonymous(x) != 0
        }
    }

    /// Get this cursor's referent's spelling.
    public func spelling(): String {
        unsafe {
            return cxstringToString(clang_getCursorSpelling(x))
        }
    }

    /// Get this cursor's referent's display name.
    ///
    /// This is not necessarily a valid identifier. It includes extra
    /// information, such as parameters for a function, etc.
    public func displayName(): String {
        unsafe {
            return cxstringToString(clang_getCursorDisplayName(x))
        }
    }

    /// Get the mangled name of this cursor's referent.
    public func mangling(): String {
        unsafe {
            return cxstringToString(clang_Cursor_getMangling(x))
        }
    }

    /// Get every mangled symbol associated with a C++ constructor or
    /// destructor. Most declarations have either one symbol or no string set.
    public func cxxManglings(): Result<Array<String>, Unit> {
        unsafe {
            let manglings = clang_Cursor_getCXXManglings(x)
            if (manglings.isNull()) {
                return Result<Array<String>, Unit>.Err(())
            }

            try {
                let stringSet = manglings.read()
                let count = stringSet.Count
                let strings = stringSet.Strings
                let values = Array<String>(Int64(count)) {
                    i => cxstringToBorrowedString((strings + i).read())
                }
                return Result<Array<String>, Unit>.Ok(values)
            } finally {
                clang_disposeStringSet(manglings)
            }
        }
    }

    public func location(): SourceLocation {
        unsafe {
            return SourceLocation(clang_getCursorLocation(x))
        }
    }

    public func isBuiltin(): Bool {
        let (file, _, _, _) = this.location().location()
        return file.name().isNone()
    }

    public func isInSystemHeader(): Bool {
        let ex = this.extent()

        unsafe {
            if (clang_Range_isNull(ex) == 0) {
                let start = clang_getRangeStart(ex)
                let ret = clang_Location_isInSystemHeader(start) != 0
                return ret
            } else {
                return false
            }
        }
    }

    public func translationUnit(): Cursor {
        unsafe {
            let tu = clang_Cursor_getTranslationUnit(x)
            let cursor = Cursor(clang_getTranslationUnitCursor(tu))
            return cursor
        }
    }

    public func isMacroFunctionLike(): Bool {
        unsafe {
            return clang_Cursor_isMacroFunctionLike(x) != 0
        }
    }

    public func kind(): CXCursorKind {
        return this.x.kind
    }

    public func isDefinition(): Bool {
        unsafe {
            return clang_isCursorDefinition(x) != 0
        }
    }

    public func isValid(): Bool {
        unsafe {
            return clang_isInvalid(this.kind()) == 0
        }
    }

    func extent(): CXSourceRange {
        unsafe {
            return clang_getCursorExtent(x)
        }
    }

    public func rawComment(): Option<String> {
        let s = unsafe {
            cxstringToString(clang_Cursor_getRawCommentText(x))
        }
        if (s.size == 0) {
            return None
        }
        return Some(s)
    }

    public func comment(): Comment {
        unsafe {
            return Comment(clang_Cursor_getParsedComment(x))
        }
    }

    public func curType(): Type {
        unsafe {
            return Type(clang_getCursorType(x))
        }
    }

    public func retType(): ?Type {
        unsafe {
            let ret = Type(clang_getCursorResultType(x))
            if (ret.isValid()) {
                return Some(ret)
            } else {
                return None
            }
        }
    }

    public func definition(): Option<Cursor> {
        unsafe {
            let ret = Cursor(clang_getCursorDefinition(x))
            if (ret.isValid() && ret.kind() != CXCursorKind_CXCursor_NoDeclFound) {
                return Some(ret)
            } else {
                return None
            }
        }
    }

    public func referenced(): Option<Cursor> {
        unsafe {
            let ret = Cursor(clang_getCursorReferenced(x))
            if (ret.isValid()) {
                return Some(ret)
            } else {
                None
            }
        }
    }

    public func canonical(): Cursor {
        unsafe {
            return Cursor(clang_getCanonicalCursor(x))
        }
    }

    /// Return the number of template arguments used by this declaration.
    /// Type metadata is preferred because cursor metadata is incomplete for
    /// some class template specializations.
    public func numTemplateArgs(): ?UInt32 {
        if (let Some(count) <- this.curType().numTemplateArgs()) {
            return Some(count)
        }

        let cursorCount = unsafe { clang_Cursor_getNumTemplateArguments(x) }
        if (cursorCount >= 0) {
            return Some(UInt32(cursorCount))
        }

        let canonicalCursor = this.canonical()
        if (canonicalCursor == this) {
            return None
        }
        return canonicalCursor.numTemplateArgs()
    }

    /// Return template arguments as types. Non-type template arguments are
    /// represented by invalid Type values and can be inspected through the
    /// cursor-specific template argument accessors below.
    public func templateArgs(): ?Array<Type> {
        if (let Some(args) <- this.curType().templateArgs()) {
            return Some(args)
        }

        let count = unsafe { clang_Cursor_getNumTemplateArguments(x) }
        if (count >= 0) {
            return Some(Array<Type>(Int64(count)) {
                i => unsafe { Type(clang_Cursor_getTemplateArgumentType(x, UInt32(i))) }
            })
        }

        let canonicalCursor = this.canonical()
        if (canonicalCursor == this) {
            return None
        }
        return canonicalCursor.templateArgs()
    }

    public func templateArgumentKind(index: UInt32): ?CXTemplateArgumentKind {
        if (let Some(count) <- this.numTemplateArgs()) {
            if (index >= count) {
                return None
            }
        } else {
            return None
        }

        let kind = unsafe { clang_Cursor_getTemplateArgumentKind(x, index) }
        if (kind == CXTemplateArgumentKind_CXTemplateArgumentKind_Invalid) {
            return None
        }
        return Some(kind)
    }

    public func templateArgumentType(index: UInt32): ?Type {
        if (this.templateArgumentKind(index) != Some(CXTemplateArgumentKind_CXTemplateArgumentKind_Type)) {
            return None
        }

        let ty = unsafe { Type(clang_Cursor_getTemplateArgumentType(x, index)) }
        if (ty.isValid()) {
            return Some(ty)
        }
        return None
    }

    public func templateArgumentValue(index: UInt32): ?Int64 {
        if (this.templateArgumentKind(index) != Some(CXTemplateArgumentKind_CXTemplateArgumentKind_Integral)) {
            return None
        }
        return Some(unsafe { clang_Cursor_getTemplateArgumentValue(x, index) })
    }

    public func templateArgumentUnsignedValue(index: UInt32): ?UInt64 {
        if (this.templateArgumentKind(index) != Some(CXTemplateArgumentKind_CXTemplateArgumentKind_Integral)) {
            return None
        }
        return Some(unsafe { clang_Cursor_getTemplateArgumentUnsignedValue(x, index) })
    }

    /// Return the primary template specialized by this declaration.
    public func specialized(): ?Cursor {
        let cursor = unsafe { Cursor(clang_getSpecializedCursorTemplate(x)) }
        if (cursor.isValid() && cursor.kind() != CXCursorKind_CXCursor_NoDeclFound) {
            return Some(cursor)
        }
        return None
    }

    /// Return the declaration kind produced by instantiating this template.
    public func templateKind(): CXCursorKind {
        unsafe {
            return clang_getTemplateCursorKind(x)
        }
    }

    public func isTemplateLike(): Bool {
        let cursorKind = this.kind()
        return cursorKind == CXCursorKind_CXCursor_ClassTemplate ||
            cursorKind == CXCursorKind_CXCursor_ClassTemplatePartialSpecialization ||
            cursorKind == CXCursorKind_CXCursor_TypeAliasTemplateDecl
    }

    public func isTemplateSpecialization(): Bool {
        return this.specialized().isSome()
    }

    public func isFullySpecializedTemplate(): Bool {
        return this.isTemplateSpecialization() &&
            this.kind() != CXCursorKind_CXCursor_ClassTemplatePartialSpecialization &&
            this.numTemplateArgs().getOrDefault({=> 0u32}) > 0
    }

    /// Return whether this declaration is outside every class or function
    /// scope. Namespace layers do not change the result.
    public func isTopLevel(): Bool {
        var parent = this.fallibleSemanticParent()
        while (let Some(parentCursor) <- parent) {
            let parentKind = parentCursor.kind()
            if (parentKind != CXCursorKind_CXCursor_Namespace &&
                parentKind != CXCursorKind_CXCursor_NamespaceAlias &&
                parentKind != CXCursorKind_CXCursor_NamespaceRef) {
                break
            }
            parent = parentCursor.fallibleSemanticParent()
        }

        match (parent) {
            case Some(parentCursor) => return parentCursor == this.translationUnit()
            case None => return false
        }
    }

    /// Return whether any enclosing template still has free parameters.
    public func isInNonFullySpecializedTemplate(): Bool {
        if (this.isTopLevel()) {
            return false
        }

        let parent = this.semanticParent()
        if (parent.isFullySpecializedTemplate()) {
            return false
        }
        if (!parent.isTemplateLike()) {
            return parent.isInNonFullySpecializedTemplate()
        }
        return true
    }

    public func isTemplateParameter(): Bool {
        let cursorKind = this.kind()
        return cursorKind == CXCursorKind_CXCursor_TemplateTemplateParameter ||
            cursorKind == CXCursorKind_CXCursor_TemplateTypeParameter ||
            cursorKind == CXCursorKind_CXCursor_NonTypeTemplateParameter
    }

    /// Return whether this declaration's type or value refers to a template
    /// parameter anywhere in its cursor tree.
    public func isDependentOnTemplateParameter(): Bool {
        if (this.isTemplateParameter()) {
            return true
        }

        let found = Box(false)
        this.visit {
            child => visitTemplateDependency(child, found)
        }
        return found.value
    }

    public func linkage(): CXLinkageKind {
        unsafe {
            return clang_getCursorLinkage(x)
        }
    }

    public func visibility(): CXVisibilityKind {
        unsafe {
            return clang_getCursorVisibility(x)
        }
    }

    public func language(): CXLanguageKind {
        unsafe {
            return clang_getCursorLanguage(x)
        }
    }

    public func isInlinedFunction(): Bool {
        unsafe {
            clang_Cursor_isFunctionInlined(x) != 0
        }
    }

    public func isDefaultedFunction(): Bool {
        unsafe {
            return clang_CXXMethod_isDefaulted(x) != 0
        }
    }

    public func isDeletedFunction(): Bool {
        unsafe {
            return clang_CXXMethod_isDeleted(x) != 0
        }
    }

    public func lexicalParent(): Cursor {
        unsafe {
            return Cursor(clang_getCursorLexicalParent(x))
        }
    }

    public func semanticParent(): Cursor {
        this.fallibleSemanticParent().getOrThrow()
    }

    public func fallibleSemanticParent(): ?Cursor {
        let pp = unsafe {
            Cursor(clang_getCursorSemanticParent(x))
        }

        let ppValid = pp.isValid()
        if (pp == this || !ppValid) {
            return None
        }
        return Some(pp)
    }

    public func numArgs(): Result<UInt32, Unit> {
        unsafe {
            let w = clang_Cursor_getNumArguments(x)
            if (w == -1) {
                return Result<UInt32, Unit>.Err(())
            } else {
                return Result<UInt32, Unit>.Ok(UInt32(w))
            }
        }
    }

    public func args(): ?Array<Cursor> {
        let numArgs = this.numArgs().ok()
        if (let Some(n) <- numArgs) {
            return Array<Cursor>(Int64(n)) {
                i => unsafe {
                    let arg = clang_Cursor_getArgument(x, UInt32(i))
                    return Cursor(arg)
                }
            }
        }
        return None
    }

    public func numOverloadedDecls(): UInt32 {
        unsafe {
            return clang_getNumOverloadedDecls(x)
        }
    }

    public func overloadedDecls(): Array<Cursor> {
        let count = this.numOverloadedDecls()
        return Array<Cursor>(Int64(count)) {
            i => unsafe { Cursor(clang_getOverloadedDecl(x, UInt32(i))) }
        }
    }

    public func accessSpecifier(): CX_CXXAccessSpecifier {
        unsafe {
            return clang_getCXXAccessSpecifier(x)
        }
    }

    /// Declarations without an explicit access specifier are accessible at
    /// namespace scope and are treated as public here.
    public func isPublic(): Bool {
        let access = this.accessSpecifier()
        return access == CX_CXXAccessSpecifier_CX_CXXPublic ||
            access == CX_CXXAccessSpecifier_CX_CXXInvalidAccessSpecifier
    }

    public func isMutableField(): Bool {
        unsafe {
            return clang_CXXField_isMutable(x) != 0
        }
    }

    public func methodIsStatic(): Bool {
        unsafe {
            return clang_CXXMethod_isStatic(x) != 0
        }
    }

    public func methodIsConst(): Bool {
        unsafe {
            return clang_CXXMethod_isConst(x) != 0
        }
    }

    public func methodIsVirtual(): Bool {
        unsafe {
            return clang_CXXMethod_isVirtual(x) != 0
        }
    }

    public func methodIsPureVirtual(): Bool {
        unsafe {
            return clang_CXXMethod_isPureVirtual(x) != 0
        }
    }

    public func methodIsCopyAssignmentOperator(): Bool {
        unsafe {
            return clang_CXXMethod_isCopyAssignmentOperator(x) != 0
        }
    }

    public func methodIsMoveAssignmentOperator(): Bool {
        unsafe {
            return clang_CXXMethod_isMoveAssignmentOperator(x) != 0
        }
    }

    public func methodIsExplicit(): Bool {
        unsafe {
            return clang_CXXMethod_isExplicit(x) != 0
        }
    }

    public func constructorIsConverting(): Bool {
        unsafe {
            return clang_CXXConstructor_isConvertingConstructor(x) != 0
        }
    }

    public func constructorIsCopy(): Bool {
        unsafe {
            return clang_CXXConstructor_isCopyConstructor(x) != 0
        }
    }

    public func constructorIsDefault(): Bool {
        unsafe {
            return clang_CXXConstructor_isDefaultConstructor(x) != 0
        }
    }

    public func constructorIsMove(): Bool {
        unsafe {
            return clang_CXXConstructor_isMoveConstructor(x) != 0
        }
    }

    public func isCxxAbstract(): Bool {
        unsafe {
            return clang_CXXRecord_isAbstract(x) != 0
        }
    }

    public func isVirtualBase(): Bool {
        unsafe {
            return clang_isVirtualBase(x) != 0
        }
    }

    public func isScopedEnum(): Bool {
        unsafe {
            return clang_EnumDecl_isScoped(x) != 0
        }
    }

    public func typedefType(): ?Type {
        let inner = unsafe {
            Type(clang_getTypedefDeclUnderlyingType(x))
        }
        if (inner.isValid()) {
            return Some(inner)
        } else {
            return None
        }
    }

    public func enumType(): ?Type {
        unsafe {
            let t = Type(clang_getEnumDeclIntegerType(x))
            if (t.isValid()) {
                return Some(t)
            } else {
                return None
            }
        }
    }

    public func enumValBoolean(): ?Bool {
        unsafe {
            if (this.kind() == CXCursorKind_CXCursor_EnumConstantDecl) {
                let v = clang_getEnumConstantDeclValue(x) != 0
                return Some(v)
            } else {
                return None
            }
        }
    }

    public func enumValSigned(): ?Int64 {
        unsafe {
            if (this.kind() == CXCursorKind_CXCursor_EnumConstantDecl) {
                let v = clang_getEnumConstantDeclValue(x)
                return Some(Int64(v))
            } else {
                None
            }
        }
    }

    public func enumValUnsigned(): ?UInt64 {
        unsafe {
            if (this.kind() == CXCursorKind_CXCursor_EnumConstantDecl) {
                let v = clang_getEnumConstantDeclUnsignedValue(x)
                return Some(v)
            } else {
                None
            }
        }
    }

    public func bitWidth(): ?UInt32 {
        unsafe {
            let w = clang_getFieldDeclBitWidth(x)
            if (w == -1) {
                None
            } else {
                Some(UInt32(w))
            }
        }
    }

    public func isBitField(): Bool {
        unsafe {
            return clang_Cursor_isBitField(x) != 0
        }
    }

    public func offsetOfFieldRaw(): Int64 {
        unsafe {
            return clang_Cursor_getOffsetOfField(x)
        }
    }

    public func evalutate(): EvalResult {
        return EvalResult(this)
    }

    public func getIncludedFileName(): ?String {
        unsafe {
            let file = clang_getIncludedFile(x)
            if (file.isNull()) {
                return None
            } else {
                return cxstringToString(clang_getFileName(file))
            }
        }
    }

    public func toString(): String {
        return "Cursor ${this.spelling()}"
    }

    public func hashCode(): Int64 {
        unsafe {
            return Int64(clang_hashCursor(x))
        }
    }

    public func visitContinue(visitor: (Cursor) -> Unit): Unit {
        this.visit {
            c =>
            visitor(c)
            return CXChildVisitResult_CXChildVisit_Continue
        }
    }

    public func visit(visitor: (Cursor) -> CXChildVisitResult): Unit {
        let cbId = getNextCallbackId()
        CursorVisitCallback.add(cbId, visitor)

        unsafe {
            let cb: CFunc<(CXCursor, CXCursor, CPointer<Unit>) -> CXChildVisitResult> = {
                cxcs, _, cbIdData =>
                    let id = CPointer<Int64>(cbIdData).read()

                    let cb = CursorVisitCallback[id].getOrThrow()
                    cb(Cursor(cxcs))
            }

            let cbIdData = LibC.malloc<Int64>(count: 1)
            cbIdData.write(cbId)

            try {
                clang_visitChildren(x, cb, CPointer<Unit>(cbIdData))
            } finally {
                LibC.free<Int64>(cbIdData)
                CursorVisitCallback.remove(cbId)
            }
        }
    }

    public func collectChildren(): ArrayList<Cursor> {
        let children = ArrayList<Cursor>()
        this.visit {
            c =>
            children.add(c)
            return CXChildVisitResult_CXChildVisit_Continue
        }
        return children
    }

    public func isInlineNamespace(): Bool {
        unsafe {
            return clang_Cursor_isInlineNamespace(x) != 0
        }
    }

    // --- ObjC support ---

    /// Get ObjC property attributes (readonly, copy, retain, etc.)
    public func objcPropertyAttributes(): UInt32 {
        unsafe {
            return clang_Cursor_getObjCPropertyAttributes(x, 0)
        }
    }

    /// Get ObjC property getter name
    public func objcPropertyGetterName(): String {
        unsafe {
            return cxstringToString(clang_Cursor_getObjCPropertyGetterName(x))
        }
    }

    /// Get ObjC property setter name
    public func objcPropertySetterName(): String {
        unsafe {
            return cxstringToString(clang_Cursor_getObjCPropertySetterName(x))
        }
    }

    /// Check if this cursor is an ObjC @optional method/property
    public func isObjCOptional(): Bool {
        unsafe {
            return clang_Cursor_isObjCOptional(x) != 0
        }
    }

    /// Get ObjC declaration qualifiers (in, out, inout, bycopy, byref, oneway)
    public func objcDeclQualifiers(): UInt32 {
        unsafe {
            return clang_Cursor_getObjCDeclQualifiers(x)
        }
    }

    /// Get ObjC selector index for this cursor
    public func objcSelectorIndex(): Int32 {
        unsafe {
            return clang_Cursor_getObjCSelectorIndex(x)
        }
    }

    /// Get ObjC type encoding for a declaration
    public func objcTypeEncoding(): String {
        unsafe {
            return cxstringToString(clang_getDeclObjCTypeEncoding(x))
        }
    }

    // cjlint-ignore -start !G.OPR.01 eq
    public operator func ==(that: Cursor): Bool {
        unsafe {
            return clang_equalCursors(x, that.x) != 0
        }
    }
    // cjlint-ignore -end eq
}

func visitTemplateDependency(cursor: Cursor, found: Box<Bool>): CXChildVisitResult {
    if (found.value) {
        return CXChildVisitResult_CXChildVisit_Break
    }

    if (cursor.isTemplateParameter()) {
        found.value = true
        return CXChildVisitResult_CXChildVisit_Break
    }

    if (let Some(referenced) <- cursor.referenced()) {
        if (referenced.isTemplateParameter()) {
            found.value = true
            return CXChildVisitResult_CXChildVisit_Break
        }

        referenced.visit {
            child => visitTemplateDependency(child, found)
        }
        if (found.value) {
            return CXChildVisitResult_CXChildVisit_Break
        }
    }

    return CXChildVisitResult_CXChildVisit_Recurse
}

public class Type <: Equatable<Type> {
    let x: CXType
    init(x: CXType) {
        this.x = x
    }

    public func declaration(): Cursor {
        unsafe {
            return Cursor(clang_getTypeDeclaration(x))
        }
    }

    public func kind(): CXTypeKind {
        return this.x.kind
    }

    public func canonicalType(): Type {
        unsafe {
            return Type(clang_getCanonicalType(x))
        }
    }

    public func isVariadic(): Bool {
        unsafe {
            return clang_isFunctionTypeVariadic(x) != 0
        }
    }

    public func retType(): ?Type {
        unsafe {
            let ret = Type(clang_getResultType(x))
            if (ret.isValid()) {
                return Some(ret)
            } else {
                return None
            }
        }
    }

    public func isValid(): Bool {
        return this.x.kind != CXTypeKind_CXType_Invalid
    }

    public func elemType(): ?Type {
        unsafe {
            let cur = Type(clang_getElementType(x))
            if (cur.isValid()) {
                return Some(cur)
            } else {
                return None
            }
        }
    }

    public func isConst(): Bool {
        unsafe {
            return clang_isConstQualifiedType(x) != 0
        }
    }

    public func isPod(): Bool {
        unsafe {
            return clang_isPODType(x) != 0
        }
    }

    public func spelling(): String {
        unsafe {
            return cxstringToString(clang_getTypeSpelling(x))
        }
    }

    public func fallibleLayoutArgs(ptrSize: UIntNative): Result<(Int64, Int64), Int64> {
        let size = this.clangSizeOf(ptrSize)
        if (size < 0) {
            return Result.Err(size)
        }

        let align = this.clangAlignOf(ptrSize)
        if (align < 0) {
            return Result.Err(align)
        }
        return Result.Ok((size, align))
    }

    public func isNonDeductibleAutoType(): Bool {
        return this.canonicalType() == this
    }

    public func size(ptrSize: UIntNative): UIntNative {
        let val = this.clangSizeOf(ptrSize)
        if (val < 0) {
            return 0
        } else {
            return UIntNative(val)
        }
    }

    public func clangSizeOf(ptrSize: UIntNative): Int64 {
        let k = this.kind()
        if (k == CXTypeKind_CXType_RValueReference || k == CXTypeKind_CXType_LValueReference) {
            return Int64(ptrSize)
        }

        if (k == CXTypeKind_CXType_Auto) {
            if (this.isNonDeductibleAutoType()) {
                return -6
            }
        }

        unsafe {
            return clang_Type_getSizeOf(x)
        }
    }

    public func align(ptrSize: UIntNative): UIntNative {
        let val = this.clangAlignOf(ptrSize)
        if (val < 0) {
            return 0
        } else {
            return UIntNative(val)
        }
    }

    public func clangAlignOf(ptrSize: UIntNative): Int64 {
        let k = this.kind()
        if (k == CXTypeKind_CXType_RValueReference || k == CXTypeKind_CXType_LValueReference) {
            return Int64(ptrSize)
        }

        if (k == CXTypeKind_CXType_Auto) {
            return -6
        }

        unsafe {
            return clang_Type_getAlignOf(x)
        }
    }

    public func args(): ?Array<Type> {
        let numArgs = this.numArgs().ok()
        match (numArgs) {
            case Some(n) => return Array<Type>(Int64(n)) {
                i => unsafe {
                    let arg = clang_getArgType(x, UInt32(i))
                    return Type(arg)
                }
            }
            case None => return None
        }
    }

    public func numArgs(): Result<UInt32, Unit> {
        unsafe {
            let w = clang_getNumArgTypes(x)
            if (w == -1) {
                Err(())
            } else {
                Ok(UInt32(w))
            }
        }
    }

    /// Get the number of template arguments for this specialization.
    public func numTemplateArgs(): ?UInt32 {
        let count = unsafe { clang_Type_getNumTemplateArguments(x) }
        if (count >= 0) {
            return Some(UInt32(count))
        }
        return None
    }

    /// Return all type positions in a class template specialization. Entries
    /// for non-type arguments are invalid Type values.
    public func templateArgs(): ?Array<Type> {
        if (let Some(count) <- this.numTemplateArgs()) {
            return Some(Array<Type>(Int64(count)) {
                i => unsafe { Type(clang_Type_getTemplateArgumentAsType(x, UInt32(i))) }
            })
        }
        return None
    }

    public func numElements(): ?UIntNative {
        let num = unsafe {
            clang_getNumElements(x)
        }
        if (num != -1) {
            return UIntNative(num)
        } else {
            return None
        }
    }

    public func canonicalDeclaration(_: ?Cursor): ?CanonicalTypeDeclaration {
        let decl = this.declaration()
        let canonical = decl.canonical()
        if (canonical.isValid() && canonical.kind() != CXCursorKind_CXCursor_NoDeclFound) {
            return CanonicalTypeDeclaration(this, canonical)
        } else {
            return None
        }
    }

    public func callConv(): CXCallingConv {
        unsafe {
            return clang_getFunctionTypeCallingConv(x)
        }
    }

    public func referenceQualifier(): CXRefQualifierKind {
        unsafe {
            return clang_Type_getCXXRefQualifier(x)
        }
    }

    public func pointeeType(): ?Type {
        let k = this.kind()
        if (k == CXTypeKind_CXType_Pointer || k == CXTypeKind_CXType_RValueReference || k == CXTypeKind_CXType_LValueReference || k ==
            CXTypeKind_CXType_MemberPointer || k == CXTypeKind_CXType_BlockPointer || k == CXTypeKind_CXType_ObjCObjectPointer) {
            unsafe {
                let p = Type(clang_getPointeeType(x))
                if (!p.isValid()) {
                    throw Exception("clang_getPointeeType failed")
                }
                return Some(p)
            }
        }
        return None
    }

    public func named(): Type {
        unsafe {
            return Type(clang_Type_getNamedType(x))
        }
    }

    public func atomicValueType(): Type {
        unsafe {
            return Type(clang_Type_getValueType(x))
        }
    }

    // --- ObjC support ---

    /// Get nullability of this type (NonNull, Nullable, Unspecified, Invalid)
    public func nullability(): CXTypeNullabilityKind {
        unsafe {
            return clang_Type_getNullability(x)
        }
    }

    public func isNullable(): Bool {
        let n = this.nullability()
        return n == CXTypeNullabilityKind_CXTypeNullability_Nullable ||
            n == CXTypeNullabilityKind_CXTypeNullability_NullableResult
    }

    /// Get ObjC type encoding string
    public func objcEncoding(): String {
        unsafe {
            return cxstringToString(clang_Type_getObjCEncoding(x))
        }
    }

    /// Get the base type of an ObjC object type
    public func objcObjectBaseType(): Type {
        unsafe {
            return Type(clang_Type_getObjCObjectBaseType(x))
        }
    }

    /// Get the number of ObjC type arguments
    public func numObjCTypeArgs(): UInt32 {
        unsafe {
            return clang_Type_getNumObjCTypeArgs(x)
        }
    }

    /// Get an ObjC type argument at the given index
    public func objcTypeArg(index: UInt32): Type {
        unsafe {
            return Type(clang_Type_getObjCTypeArg(x, index))
        }
    }

    /// Get the number of ObjC protocol references
    public func numObjCProtocolRefs(): UInt32 {
        unsafe {
            return clang_Type_getNumObjCProtocolRefs(x)
        }
    }

    /// Get ObjC protocol declaration at the given index
    public func objcProtocolDecl(index: UInt32): Cursor {
        unsafe {
            return Cursor(clang_Type_getObjCProtocolDecl(x, index))
        }
    }

    // cjlint-ignore -start !G.OPR.01 eq
    public operator func ==(rhs: Type): Bool {
        unsafe {
            return clang_equalTypes(x, rhs.x) != 0
        }
    }
    // cjlint-ignore -end eq
}

public class Comment {
    let x: CXComment
    init(x: CXComment) {
        this.x = x
    }
}

public class SourceLocation {
    let x: CXSourceLocation
    init(x: CXSourceLocation) {
        this.x = x
    }

    public func location(): (File, UInt32, UInt32, UInt32) {
        unsafe {
            var file = CXFile()
            var line = UInt32(0)
            var column = UInt32(0)
            var offset = UInt32(0)
            clang_getFileLocation(
                this.x,
                inout file,
                inout line,
                inout column,
                inout offset
            )
            return (File(file), line, column, offset)
        }
    }
}

public class File {
    let x: CXFile
    init(x: CXFile) {
        this.x = x
    }

    public func name(): Option<String> {
        if (x.isNull()) {
            return None
        }

        unsafe {
            let s = cxstringToString(clang_getFileName(x))
            if (s.isEmpty()) {
                return None
            }
            return Some(s)
        }
    }
}

public class Index <: Resource {
    let x: CXIndex
    var _released: Bool = false

    public func isClosed(): Bool { _released }

    public func close(): Unit {
        if (!_released) {
            _released = true
            unsafe { clang_disposeIndex(x) }
        }
    }

    public init(pch: Bool, diag: Bool) {
        let pch_c: Int32 = if (pch) {
            1
        } else {
            0
        }
        let diag_c: Int32 = if (diag) {
            1
        } else {
            0
        }

        unsafe {
            this.x = clang_createIndex(pch_c, diag_c)
        }
    }

}

extend CString {
    func toPtr(): CPointer<Int8> {
        return CPointer<Int8>(this.getChars())
    }
}

public class TranslationUnit <: Resource {
    var x: CXTranslationUnit
    var _released: Bool = false

    public func isClosed(): Bool { _released }

    public func close(): Unit {
        if (!_released) {
            _released = true
            unsafe { clang_disposeTranslationUnit(x) }
        }
    }


    public init(
        ix: Index,
        file: String,
        cmdArgs: Array<String>,
        options: CXTranslationUnit_Flags
    ) {
        unsafe {
            let fname = CStringOwned(file)

            let releaser = ArrayList<() -> Unit>()
            releaser.add({=> fname.close()})

            let c_args = LibC.malloc<CString>(count: cmdArgs.size)
            releaser.add({=> LibC.free(c_args)})

            for (i in 0..cmdArgs.size) {
                let s = LibC.mallocCString(cmdArgs[i])
                let ptr = c_args + i
                ptr.write(s)
                releaser.add({=> LibC.free(s)})
            }

            let unsaved = CPointer<CXUnsavedFile>()

            var tu = CXTranslationUnit()

            let code = clang_parseTranslationUnit2(
                ix.x,
                fname.pointer,
                c_args,
                Int32(cmdArgs.size),
                unsaved,
                0,
                UInt32(options),
                inout tu
            )

            if (tu.isNull()) {
                throw Exception("parse failed ${code}")
            }

            this.x = tu

            for(v in releaser) {
                v()
            }
        }
    }

    public func diags(): Array<Diagnostic> {
        unsafe {
            let cnt = clang_getNumDiagnostics(x)
            return Array<Diagnostic>(Int64(cnt)) {
                i => return Diagnostic(clang_getDiagnostic(this.x, UInt32(i)))
            }
        }
    }

    public func cursor(): Cursor {
        unsafe {
            return Cursor(clang_getTranslationUnitCursor(x))
        }
    }

    public func isNull(): Bool {
        return this.x.isNull()
    }

    public func save(file: String): Result<Unit, CXSaveError> {
        let fs = CStringOwned(file)
        try {
            unsafe {
                let ret = clang_saveTranslationUnit(
                    this.x,
                    fs.pointer,
                    clang_defaultSaveOptions(this.x)
                )
                if (ret != 0) {
                    return Result.Err(UInt32(ret))
                } else {
                    return Result.Ok(())
                }
            }
        } finally {
            fs.close()
        }
    }

}

public class UnsavedFile {
    public let x: CXUnsavedFile
    public let name: CString
    public let contents: CString

    public init(name: String, contents: String) {
        unsafe {
            let name = LibC.mallocCString(name)
            let contents = LibC.mallocCString(contents)
            this.name = name
            this.contents = contents
            this.x = CXUnsavedFile(
                name,
                contents,
                UInt64(contents.size())
            )
        }
    }

}

public class FallbackTranslationUnit <: Resource {
    public let filePath: String
    public let pchPath: String
    public let idx: Index
    public let tu: TranslationUnit
    var _released: Bool = false

    public init(
        file: String,
        pch_path: String,
        cArgs: Array<String>
    ) {
        let buf = Array<Byte>()
        FSFile.writeTo(file, buf)

        let fIndex = Index(true, false)
        let fTranslationUnit = TranslationUnit(
            fIndex,
            file,
            cArgs,
            CXTranslationUnit_Flags_CXTranslationUnit_None
        )

        this.filePath = file
        this.pchPath = pch_path
        this.idx = fIndex
        this.tu = fTranslationUnit
    }

    public func isClosed(): Bool { _released }

    public func close(): Unit {
        if (!_released) {
            _released = true
            this.tu.close()
            this.idx.close()
            try { remove(this.filePath) } catch (_: Exception) {}
            try { remove(this.pchPath) } catch (_: Exception) {}
        }
    }


    public func reparse(
        unsavedContents: String
    ): Result<Unit, CXErrorCode> {
        let content = CStringOwned(unsavedContents)
        try {
            unsafe {
                let uf = UnsavedFile(this.filePath, unsavedContents)
                var unsaved: VArray<CXUnsavedFile, $1> = [uf.x]

                let ret = clang_reparseTranslationUnit(
                    this.tu.x,
                    1,
                    inout unsaved,
                    clang_defaultReparseOptions(this.tu.x)
                )

                if (ret != 0) {
                    return Result.Err(UInt32(ret))
                } else {
                    return Result.Ok(())
                }
            }
        } finally {
            content.close()
        }
    }
}

public enum ABIKind {
    GenericItanium
    | Microsoft
}

public class TargetInfo {
    public let triple: String
    public let pointerWidth: Int32
    public let abi: ABIKind

    public init(tu: TranslationUnit) {
        let ti = unsafe { OwnedTargetInfo(clang_getTranslationUnitTargetInfo(tu.x)) }
        this.triple = ti.triple
        this.pointerWidth = ti.pointerWidth

        if (!(pointerWidth > 0)) {
            throw Exception("pointer width is not > 0")
        }
        if (!(pointerWidth % 8 == 0)) {
            throw Exception("pointer width is not a multiple of 8")
        }

        this.abi = if (this.triple.contains("msvc")) {
            ABIKind.Microsoft
        } else {
            ABIKind.GenericItanium
        }
    }
}

public class Diagnostic <: ToString & Resource {
    public let x: CXDiagnostic
    var _released: Bool = false

    init(x: CXDiagnostic) {
        this.x = x
    }

    public func isClosed(): Bool { _released }

    public func close(): Unit {
        if (!_released) {
            _released = true
            unsafe { clang_disposeDiagnostic(x) }
        }
    }

    public func toString(): String {
        unsafe {
            let opts = clang_defaultDiagnosticDisplayOptions();
            return cxstringToString(clang_formatDiagnostic(x, opts))
        }
    }

    public func severity(): CXDiagnosticSeverity {
        unsafe {
            return clang_getDiagnosticSeverity(x)
        }
    }
}

public class CanonicalTypeDeclaration {
    public let ty: Type
    public let cursor: Cursor

    public init(
        ty: Type,
        cursor: Cursor
    ) {
        this.ty = ty
        this.cursor = cursor
    }
}

public class RawTokens <: Iterable<ClangToken> & Resource {
    public let cursor: Cursor
    let _owned: OwnedTokens
    var _released: Bool = false

    public init(cursor: Cursor) {
        var tokens = CPointer<CXToken>()
        var tokenCount = UInt32(0)
        let range = cursor.extent()
        unsafe {
            let tu = clang_Cursor_getTranslationUnit(cursor.x)
            clang_tokenize(
                tu,
                range,
                inout tokens,
                inout tokenCount,
            )

            this.cursor = cursor
            this._owned = OwnedTokens(tu, tokens, tokenCount)
        }
    }

    public func isClosed(): Bool { _released }

    public func close(): Unit {
        if (!_released) {
            _released = true
            _owned.close()
        }
    }

    // The translation unit that owns the token array (non-owning reference).
    public prop tu: CXTranslationUnit {
        get() { return _owned.tu }
    }

    // Pointer to the token array.
    public prop tokens: CPointer<CXToken> {
        get() { return _owned.tokens }
    }

    // Number of tokens in the array.
    public prop tokenCount: UInt32 {
        get() { return _owned.count }
    }

    public func iterator(): ClangTokenIterator {
        return ClangTokenIterator(this)
    }
}

public class ClangToken {
    let _spelling: String
    let extent: CXSourceRange
    public let kind: CXTokenKind

    init(
        spelling: String,
        kind: CXTokenKind,
        range: CXSourceRange
    ) {
        this._spelling = spelling
        this.extent = range
        this.kind = kind
    }

    public func spelling(): String {
        return _spelling
    }
}

public class ClangTokenIterator <: Iterator<ClangToken> {
    public let rt: RawTokens
    var cur: Int64 = 0

    public init(rt: RawTokens) {
        this.rt = rt
    }

    public func next(): Option<ClangToken> {
        if (this.cur >= Int64(rt.tokenCount)) {
            return None
        }

        unsafe {
            let ptr = rt.tokens + Int64(cur)
            let data = ptr.read()

            let kind = clang_getTokenKind(data)
            let spell = cxstringToString(clang_getTokenSpelling(rt.tu, data))
            let extent = clang_getTokenExtent(rt.tu, data)

            this.cur += 1

            return ClangToken(spell, kind, extent)
        }
    }
}

public enum EvalResultInt {
    Int(Int64) |
    UInt(UInt64)
}

public class EvalResult <: Resource {
    let x: CXEvalResult
    let ty: Type
    var _released: Bool = false

    public init(cursor: Cursor) {
        unsafe {
            this.x = clang_Cursor_Evaluate(cursor.x)
            this.ty = cursor.curType().canonicalType()
        }
    }

    public func isClosed(): Bool { _released }

    public func close(): Unit {
        if (!_released) {
            _released = true
            unsafe { clang_EvalResult_dispose(x) }
        }
    }

    public func kind(): CXEvalResultKind {
        unsafe {
            return clang_EvalResult_getKind(x)
        }
    }

    public func asDouble(): ?Float64 {
        if (this.kind() == CXEvalResultKind_CXEval_Float) {
            unsafe {
                return clang_EvalResult_getAsDouble(x)
            }
        } else {
            return None
        }
    }

    public func asInt(): ?EvalResultInt {
        if (this.kind() != CXEvalResultKind_CXEval_Int) {
            return None
        }

        unsafe {
            if (clang_EvalResult_isUnsignedInt(x) != 0) {
                let v = clang_EvalResult_getAsUnsigned(x)

                return Some(EvalResultInt.UInt(UInt64(v)))
            }

            let v = clang_EvalResult_getAsLongLong(x)
            return Some(EvalResultInt.Int(v))
        }
    }

    public func asLiteralString(): ?CString {
        if (this.kind() != CXEvalResultKind_CXEval_StrLiteral) {
            return None
        }

        var charTyO = this.ty.pointeeType()
        if (charTyO.isNone()) {
            charTyO = this.ty.elemType()
        }
        if (charTyO.isNone()) {
            return None
        }
        let charTy = charTyO.getOrThrow()
        let k = charTy.kind()
        if (k == CXTypeKind_CXType_Char_S ||
        k == CXTypeKind_CXType_SChar ||
        k == CXTypeKind_CXType_Char_U ||
        k == CXTypeKind_CXType_UChar
        ) {
            unsafe {
                let ret = clang_EvalResult_getAsStr(x)
                // Copy the string to prevent use-after-free when EvalResult is disposed.
                // Cannot use LibC.mallocCString(ret.toString()) because the string may contain invalid UTF-8.
                let len = ret.size()
                let buf = LibC.malloc<UInt8>(count: Int64(len) + 1)
                for (i in 0..len) {
                    (buf + i).write((ret.getChars() + i).read())
                }
                (buf + len).write(0u8)
                let copied = CString(buf)
                return Some(copied)
            }
        }

        return None
    }
}

public func isValidIdentifier(name: String): Bool {
    let runes = name.toRuneArray()
    if (runes.isEmpty()) {
        return false
    }
    let it = runes.iterator()
    let first = it.next().getOrThrow()
    if (!first.isAsciiLetter() && first != r'_') {
        return false
    }

    for (r in it) {
        if (!r.isAsciiNumberOrLetter() && r != r'_') {
            return false
        }
    }

    return true
}
