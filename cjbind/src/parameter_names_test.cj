package cjbind

import cjbind.options.{CjbindOptions, DefaultAliasStyle}
import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.process.executeWithOutput
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class ParameterNameGenerationTest {
    @TestCase
    func keepsDeclarationsCallbacksAndWrapperCallsConsistent(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("parameter_names.h")
            File.writeTo(header,
                """
void unnamed_first(int, int arg1);
void unnamed_last(int arg1, int);
void keyword_collision(int type, int type_, int type__1);
int identity(int identity);
typedef int Strong;
Strong alias_collision(Strong arg1, Strong);
Strong alias_shadow(Strong alias_shadow);
typedef int (*Callback)(int arg1, int);
struct Callbacks { int (*callback)(int arg1, int); };
"""
                    .toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.makeFuncWrapper = true
            options.defaultAliasStyle = DefaultAliasStyle.NewType
            options.clangArgs.add(all: ["-x", "c", "--target=x86_64-w64-mingw32"])
            let binding = generate(options)

            @Expect(binding.contains("unnamed_first ( arg2: Int32 , arg1: Int32 )"), true)
            @Expect(binding.contains("return unnamed_first( arg2 , arg1 )"), true)
            @Expect(binding.contains("unnamed_last ( arg1: Int32 , arg2: Int32 )"), true)
            @Expect(binding.contains("return unnamed_last( arg1 , arg2 )"), true)
            @Expect(binding.contains("keyword_collision ( type_: Int32 , type__2: Int32 , type__1: Int32 )"), true)
            @Expect(binding.contains("return keyword_collision( type_ , type__2 , type__1 )"), true)
            @Expect(binding.contains("identity ( identity_1: Int32 )"), true)
            @Expect(binding.contains("return identity( identity_1 )"), true)
            @Expect(binding.contains("alias_collision ( arg1: Int32 , arg2: Int32 )"), true)
            @Expect(binding.contains("alias_collision_cjbindwrapper ( arg1: Strong , arg2: Strong )"), true)
            @Expect(binding.contains("alias_collision( arg1.rawValue , arg2.rawValue )"), true)
            @Expect(binding.contains("alias_shadow_cjbindwrapper ( alias_shadow_1: Strong )"), true)
            @Expect(binding.contains("alias_shadow( alias_shadow_1.rawValue )"), true)
            @Expect(binding.contains("CFunc<(arg1: Int32 , arg2: Int32) -> Int32>"), true)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func keepsGenericCallbackParameterNamesUnique(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("parameter_names.hpp")
            File.writeTo(header,
                """
template <typename T> using Callback = int (*)(T* arg1, T*, int type, int type_);
Callback<int> round_trip(Callback<int> callback);
"""
                    .toArray())
            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.clangArgs.add(all: ["-x", "c++", "-std=c++14", "--target=x86_64-w64-mingw32"])
            let binding = generate(options)

            @Expect(binding.contains("arg1: CPointer<T> , arg2: CPointer<T> , type_: Int32 , type__1: Int32"), true)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func keepsObjcNullableDeclarationsAndCallsConsistent(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("parameter_names_objc.h")
            File.writeTo(header,
                """
@interface NameProbe
- (int)take:(int)type other:(int)type_;
- (int)takeSelector:(int)sel callback:(int)f;
+ (int)takeClass:(int)cls selector:(int)sel callback:(int)f;
@end
"""
                    .toArray())
            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.objc = true
            options.clangArgs.add(all: ["-x", "objective-c", "--target=x86_64-apple-macosx"])
            let binding = generate(options)

            @Expect(binding.contains("take_other(type_ : Int32 , type__1 : Int32)"), true)
            @Expect(binding.contains("f(this.id, sel, type_ , type__1)"), true)
            @Expect(binding.contains("takeSelector_callback(sel_1 : Int32 , f_1 : Int32)"), true)
            @Expect(binding.contains("f(this.id, sel, sel_1 , f_1)"), true)
            @Expect(binding.contains("takeClass_selector_callback(cls_1 : Int32 , sel_1 : Int32 , f_1 : Int32)"), true)
            @Expect(binding.contains("f(CPointer<Unit>(cls), sel, cls_1 , sel_1 , f_1)"), true)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func keepsStaticBridgeAndNestedCallbackParameterNamesUnique(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("parameter_names.hpp")
            File.writeTo(header,
                """
static int unnamed_first(int, int arg_1) { return arg_1; }
static int unnamed_last(int arg_1, int) { return arg_1; }
static int nested_callback(int (*callback)(int arg_1, int)) { return callback(1, 2); }
static int identity(int identity) { return identity; }
"""
                    .toArray())
            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.wrapStaticFns = true
            options.wrapStaticFnsPath = Some(directory.join("bridge.generated").toString())
            options.clangArgs.add(all: ["-x", "c++", "-std=c++14"])
            generate(options)
            let source = directory.join("bridge.cpp")
            let sourceCode = String.fromUtf8(File.readFrom(source))

            @Expect(sourceCode.contains("unnamed_first__extern(int arg_2, int arg_1)"), true)
            @Expect(sourceCode.contains("unnamed_first(arg_2, arg_1)"), true)
            @Expect(sourceCode.contains("unnamed_last__extern(int arg_1, int arg_2)"), true)
            @Expect(sourceCode.contains("unnamed_last(arg_1, arg_2)"), true)
            @Expect(sourceCode.contains("(*callback) (int arg_1, int arg_2)"), true)
            @Expect(sourceCode.contains("identity__extern(int identity_1)"), true)
            @Expect(sourceCode.contains("identity(identity_1)"), true)
            let (exitCode, _, _) = executeWithOutput("clang", ["-std=c++14", "-fsyntax-only", source.toString()])
            @Expect(exitCode, 0)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
