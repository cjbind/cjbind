package cjbind

import cjbind.clang
import cjbind.options.CjbindOptions
import std.convert.*
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class ExplicitObjectMethodTest {
    @TestCase
    func preservesDeclaredObjectParametersAndImplicitReceivers(): Unit {
        // cjbind supports libclang 17, but explicit-object parsing starts in 18.
        let versionParts = clang.getClangVersion().split("version ", 2)
        if (versionParts.size == 2 && Int64.parse(versionParts[1].split(".", 2)[0]) < 18) {
            return
        }
        let options = CjbindOptions()
        options.headers.add("cjbind_test/testdata/headers/support/ir/cxx-explicit-object.hpp")
        options.noDetectIncludePath = true
        options.clangArgs.add(all: ["-x", "c++", "-std=c++23", "--target=x86_64-unknown-linux-gnu"])
        let binding = generate(options)

        @Expect(binding.contains("ExplicitObject_value ( self: ExplicitObject , y: Int32 )"), true)
        @Expect(binding.contains("ExplicitObject_reference ( self: CPointer<ExplicitObject> , y: Int32 )"), true)
        @Expect(binding.contains("ExplicitObject_regular ( this_: CPointer<ExplicitObject> , y: Int32 )"), true)
        @Expect(binding.contains("ExplicitObject_static_method ( y: Int32 )"), true)
        @Expect(binding.contains("ExplicitObject_overloaded ( self: ExplicitObject , y: Int32 )"), true)
        @Expect(binding.contains("ExplicitObject_overloaded1 ( self: ExplicitObject , y: Float64 )"), true)
        @Expect(binding.contains("this_: CPointer<ExplicitObject> , self:"), false)
        @Expect(binding.contains("ImplicitObject_constructor ( this_: CPointer<ImplicitObject> )"), true)
        @Expect(binding.contains("ImplicitObject_ImplicitObject_destructor ( this_: CPointer<ImplicitObject> )"), true)
    }
}
