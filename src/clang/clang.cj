package cjbind.clang

func cxstringToString(x: CXString): String {
    if (x.data.isNull()) {
        return ""
    }

    unsafe {
        let str = clang_getCString(x).toString()
        clang_disposeString(x)
        return str
    }
}

public struct Cursor <: ToString {
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

    public func location(): SourceLocation {
        unsafe {
            return SourceLocation(clang_getCursorLocation(x))
        }
    }

    public func isBuiltin(): Bool {
        let (file, _, _, _) = this.location().location()
        return file.name().isNone()
    }

    public func translationUnit() : Cursor {
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

    public func kind() : CXCursorKind {
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

    func extent() : CXSourceRange {
        unsafe {
            return clang_getCursorExtent(x)
        }
    }

    public func rawComment() : Option<String> {
        let s = unsafe {
            cxstringToString(clang_Cursor_getRawCommentText(x))
        }
        if (s.size == 0) {
            return None
        }
        return Some(s)
    }

    public func comment() : Comment {
        unsafe {
            return Comment(clang_Cursor_getParsedComment(x))
        }
    }

    public func curType() : Type {
        unsafe {
            return Type(clang_getCursorType(x))
        }
    }

    public func definition() : Option<Cursor> {
        unsafe {
            let ret = Cursor(clang_getCursorDefinition(x))
            if (ret.isValid() && ret.kind() != CXCursor_NoDeclFound) {
                return Some(ret)
            } else {
                return None
            }
        }
    }

    public func referenced() : Option<Cursor> {
        unsafe {
            let ret = Cursor(clang_getCursorReferenced(x))
            if (ret.isValid()) {
                return Some(ret)
            } else {
                None
            }
        }
    }

    public func canonical() : Cursor {
        unsafe {
            return Cursor(clang_getCanonicalCursor(x))
        }
    }


    public func toString(): String {
        return ""
    }

    
}

public struct Type <: Equatable<Type> {
    let x: CXType
    init(x: CXType) {
        this.x = x
    }

    // cjlint-ignore -start !G.OPR.01 eq
    public operator func ==(rhs: Type): Bool {
        unsafe {
            return clang_equalTypes(x, rhs.x) != 0
        }
    }
    // cjlint-ignore -end eq
}

public struct Comment {
    let x: CXComment
    init(x: CXComment) {
        this.x = x
    }
}

public struct SourceLocation {
    let x: CXSourceLocation
    init(x: CXSourceLocation) {
        this.x = x
    }

    public func location() : (File, UInt32, UInt32, UInt32) {
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

public struct File {
    let x: CXFile
    init(x: CXFile) {
        this.x = x
    }

    public func name(): Option<String> {
        if (x.isNull()) {
            return None
        }

        unsafe {
            return cxstringToString(clang_getFileName(x))
        }
    }

}