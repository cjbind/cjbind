package cjbind.options

import std.unittest.*
import std.unittest.testmacro.*

@Test
public class DefaultEnumStyleTest {
    @TestCase
    func equality(): Unit {
        @Expect(DefaultEnumStyle.Consts == DefaultEnumStyle.Consts, true)
        @Expect(DefaultEnumStyle.NewType == DefaultEnumStyle.NewType, true)
        @Expect(DefaultEnumStyle.Consts == DefaultEnumStyle.NewType, false)
    }
}

@Test
public class ObjcCodegenModeTest {
    @TestCase
    func equality(): Unit {
        @Expect(ObjcCodegenMode.Runtime == ObjcCodegenMode.Runtime, true)
        @Expect(ObjcCodegenMode.Compiler == ObjcCodegenMode.Compiler, true)
        @Expect(ObjcCodegenMode.Runtime == ObjcCodegenMode.Compiler, false)
    }
}

@Test
public class CjbindOptionsDefaultsTest {
    @TestCase
    func defaultValues(): Unit {
        let opts = CjbindOptions()
        @Expect(opts.packageName, "cjbind_ffi")
        @Expect(opts.noEnumPrefix, false)
        @Expect(opts.noDetectIncludePath, false)
        @Expect(opts.noLayoutTests, false)
        @Expect(opts.builtins, false)
        @Expect(opts.noComment, false)
        @Expect(opts.makeFuncWrapper, false)
        @Expect(opts.funcWrapperSuffix, "_cjbindwrapper")
        @Expect(opts.autoCString, false)
        @Expect(opts.arrayPointersInArgs, false)
        @Expect(opts.makeCjString, false)
        @Expect(opts.objc, false)
        @Expect(opts.objcCodegenMode == ObjcCodegenMode.Runtime, true)
        @Expect(opts.objcGenerateDefinitions, false)
        @Expect(opts.defaultEnumStyle == DefaultEnumStyle.Consts, true)
        @Expect(opts.fitMacroConstants, false)
        @Expect(opts.useUnionAccessorWorkaround, true)
        @Expect(opts.enableCxxNamespaces, false)
        @Expect(opts.conservativeInlineNamespaces, false)
        @Expect(opts.generateFunctions, true)
        @Expect(opts.generateTypes, true)
        @Expect(opts.generateVars, true)
        @Expect(opts.generateMethods, true)
        @Expect(opts.generateConstructors, true)
        @Expect(opts.generateDestructors, true)
        @Expect(opts.representCxxOperators, false)
        @Expect(opts.respectCxxAccessSpecs, false)
        @Expect(opts.useSpecificVirtualFunctionReceiver, false)
        @Expect(opts.generateInlineFunctions, false)
        @Expect(opts.generateDeletedFunctions, false)
        @Expect(opts.generatePureVirtualFunctions, false)
        @Expect(opts.generatePrivateFunctions, false)
        @Expect(opts.vtableGeneration, false)
        @Expect(opts.allowlistRecursively, true)
        @Expect(opts.recordMatches, true)
        @Expect(opts.untaggedUnion, true)
        @Expect(opts.sizeTIsUsize, true)
        @Expect(opts.blocklistedTypes.size, 0)
        @Expect(opts.blocklistedFunctions.size, 0)
        @Expect(opts.blocklistedItems.size, 0)
        @Expect(opts.blocklistedVars.size, 0)
        @Expect(opts.blocklistedFiles.size, 0)
        @Expect(opts.opaqueTypes.size, 0)
        @Expect(opts.allowlistedTypes.size, 0)
        @Expect(opts.allowlistedFunctions.size, 0)
        @Expect(opts.allowlistedItems.size, 0)
        @Expect(opts.allowlistedVars.size, 0)
        @Expect(opts.allowlistedFiles.size, 0)
        @Expect(opts.fieldNameCallback.isNone(), true)
    }

    @TestCase
    func emptyCollections(): Unit {
        let opts = CjbindOptions()
        @Expect(opts.headers.size, 0)
        @Expect(opts.clangArgs.size, 0)
    }

    @TestCase
    func constructorWithCollections(): Unit {
        let opts = CjbindOptions(["header.h", "other.h"], ["-I/usr/include"])
        @Expect(opts.headers.size, 2)
        @Expect(opts.headers[0], "header.h")
        @Expect(opts.headers[1], "other.h")
        @Expect(opts.clangArgs.size, 1)
        @Expect(opts.clangArgs[0], "-I/usr/include")
    }

    @TestCase
    func mutableFields(): Unit {
        let opts = CjbindOptions()
        opts.packageName = "my_package"
        opts.noEnumPrefix = true
        opts.makeFuncWrapper = true
        opts.funcWrapperSuffix = "_wrap"
        opts.defaultEnumStyle = DefaultEnumStyle.NewType
        opts.objcCodegenMode = ObjcCodegenMode.Compiler
        opts.useUnionAccessorWorkaround = false
        opts.enableCxxNamespaces = true
        opts.conservativeInlineNamespaces = true
        opts.generateFunctions = false
        opts.generateTypes = false
        opts.generateVars = false
        opts.generateMethods = false
        opts.generateConstructors = false
        opts.generateDestructors = false
        opts.representCxxOperators = true
        opts.respectCxxAccessSpecs = true
        opts.useSpecificVirtualFunctionReceiver = true
        opts.generateInlineFunctions = true
        opts.generateDeletedFunctions = true
        opts.generatePureVirtualFunctions = true
        opts.generatePrivateFunctions = true
        opts.vtableGeneration = true
        opts.fieldNameCallback = { info: FieldInfo => Some("renamed_${info.fieldName}") }

        @Expect(opts.packageName, "my_package")
        @Expect(opts.noEnumPrefix, true)
        @Expect(opts.makeFuncWrapper, true)
        @Expect(opts.funcWrapperSuffix, "_wrap")
        @Expect(opts.defaultEnumStyle == DefaultEnumStyle.NewType, true)
        @Expect(opts.objcCodegenMode == ObjcCodegenMode.Compiler, true)
        @Expect(opts.useUnionAccessorWorkaround, false)
        @Expect(opts.enableCxxNamespaces, true)
        @Expect(opts.conservativeInlineNamespaces, true)
        @Expect(opts.generateFunctions, false)
        @Expect(opts.generateTypes, false)
        @Expect(opts.generateVars, false)
        @Expect(opts.generateMethods, false)
        @Expect(opts.generateConstructors, false)
        @Expect(opts.generateDestructors, false)
        @Expect(opts.representCxxOperators, true)
        @Expect(opts.respectCxxAccessSpecs, true)
        @Expect(opts.useSpecificVirtualFunctionReceiver, true)
        @Expect(opts.generateInlineFunctions, true)
        @Expect(opts.generateDeletedFunctions, true)
        @Expect(opts.generatePureVirtualFunctions, true)
        @Expect(opts.generatePrivateFunctions, true)
        @Expect(opts.vtableGeneration, true)
        @Expect(opts.fieldNameCallback.isSome(), true)
    }

    @TestCase
    func namePatternSetsUseRegularExpressions(): Unit {
        let opts = CjbindOptions()
        opts.blocklistedTypes.add(#"^ns::Hidden.*$"#)
        opts.blocklistedTypes.add(#"^ns::Unused.*$"#)
        @Expect(opts.blocklistedTypes.isEmpty, false)
        @Expect(opts.blocklistedTypes.matches("ns::HiddenType"), true)
        @Expect(opts.blocklistedTypes.matches("ns::VisibleType"), false)
        @Expect(opts.blocklistedTypes.toArray()[0], #"^ns::Hidden.*$"#)
        @Expect(opts.blocklistedTypes.unmatchedPatterns(), [#"^ns::Unused.*$"#])
    }

    @TestCase
    func namePatternSetsMatchTheWholeItemName(): Unit {
        let patterns = NamePatternSet()
        patterns.add("Hidden")
        @Expect(patterns.matches("Hidden"), true)
        @Expect(patterns.matches("ns::Hidden"), false)

        let wildcard = NamePatternSet()
        wildcard.add(".*Hidden")
        @Expect(wildcard.matches("ns::Hidden"), true)
    }

    @TestCase
    func alternationIsAnchoredAsOneWholePattern(): Unit {
        let patterns = NamePatternSet()
        patterns.add("Visible|Hidden")
        @Expect(patterns.matches("Visible"), true)
        @Expect(patterns.matches("Hidden"), true)
        @Expect(patterns.matches("ns::Visible"), false)
        @Expect(patterns.matches("HiddenSuffix"), false)
    }

    @TestCase
    func oneNameRecordsEveryOverlappingPattern(): Unit {
        let patterns = NamePatternSet()
        patterns.add("Visible.*")
        patterns.add(".*Type")
        @Expect(patterns.matches("VisibleType"), true)
        @Expect(patterns.unmatchedPatterns().isEmpty(), true)
    }

    @TestCase
    func invalidRegexDisablesTheWholePatternSet(): Unit {
        let patterns = NamePatternSet()
        patterns.add("Visible")
        patterns.add("[")
        @Expect(patterns.matches("Visible"), false)
        @Expect(patterns.unmatchedPatterns(), ["Visible", "["])
    }

}
