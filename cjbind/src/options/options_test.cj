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

        @Expect(opts.packageName, "my_package")
        @Expect(opts.noEnumPrefix, true)
        @Expect(opts.makeFuncWrapper, true)
        @Expect(opts.funcWrapperSuffix, "_wrap")
        @Expect(opts.defaultEnumStyle == DefaultEnumStyle.NewType, true)
        @Expect(opts.objcCodegenMode == ObjcCodegenMode.Compiler, true)
    }
}
