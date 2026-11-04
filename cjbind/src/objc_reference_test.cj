package cjbind

import cjbind.options.{CjbindOptions, ObjcCodegenMode}
import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.process.executeWithOutput
import std.unittest.*
import std.unittest.testmacro.*

@Test
public class ObjCReferenceGenerationTest {
    @TestCase
    func emitsOneDefinitionForEveryReferencedClass(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("objects.h")
            File.writeTo(header, """
@class Peer;
@interface Sample
- (Sample *)copy;
- (void)consume:(Sample *)value;
- (Peer *)peer;
@property Sample *object;
@end
@interface Peer
- (Sample *)owner;
@end
""".toArray())
            for (mode in [ObjcCodegenMode.Runtime, ObjcCodegenMode.Compiler]) {
                let options = CjbindOptions()
                options.headers.add(header.toString())
                options.noDetectIncludePath = true
                options.objc = true
                options.objcCodegenMode = mode
                options.clangArgs.add("--target=x86_64-apple-darwin")
                let binding = generate(options)
                @Expect(binding.split("class Sample").size, 2)
                @Expect(binding.split("class Peer").size, 2)
                if (mode == ObjcCodegenMode.Runtime) {
                    @Expect(binding.contains("-> Sample>"), false)
                    @Expect(binding.contains("-> Peer>"), false)
                    @Expect(binding.contains("return Sample(unsafe { f(this.id, sel) })"), true)
                    @Expect(binding.contains("f(this.id, sel, value.id)"), true)
                    let generated = directory.join("objects.cj")
                    File.writeTo(generated, binding.toArray())
                    let (exitCode, _, stderr) = executeWithOutput("cjc", [
                        generated.toString(), "--output-type=staticlib", "-Woff", "unused",
                        "-o", directory.join("objects.a").toString()
                    ])
                    if (exitCode != 0) {
                        throw Exception("ObjC binding compilation failed: ${String.fromUtf8(stderr)}")
                    }
                }
            }
        } finally {
            remove(directory, recursive: true)
        }
    }
}
