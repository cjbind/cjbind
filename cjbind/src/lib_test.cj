package cjbind

import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.unittest.*
import std.unittest.testmacro.*
import cjbind.options.CjbindOptions

@Test
public class GenerateValidationTest {
    @TestCase
    func rejectsMissingHeaders(): Unit {
        var rejected = false
        try {
            generate(CjbindOptions())
        } catch (e: Exception) {
            rejected = e.message.contains("没有指定头文件")
        }
        @Expect(rejected, true)
    }

    @TestCase
    func includeDetectionDoesNotMutateOptions(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("repeated_generation.h")
            File.writeTo(header, "int repeated_generation(int value);".toArray())
            let options = CjbindOptions([header.toString()], ["-x", "c"])
            options.noLayoutTests = true

            let first = generate(options)
            @Expect(options.clangArgs.toArray(), ["-x", "c"])
            let second = generate(options)
            @Expect(options.clangArgs.toArray(), ["-x", "c"])
            @Expect(first, second)
            @Expect(second.contains("repeated_generation"), true)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func injectsCompilerOptionsBeforeClangArgumentSeparator(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let preincluded = directory.join("preincluded.h")
            let header = directory.join("with_separator.h")
            File.writeTo(preincluded, "typedef int MarkerAlias;".toArray())
            File.writeTo(header, "MarkerAlias marker_function(MarkerAlias value);".toArray())
            let options = CjbindOptions([preincluded.toString(), header.toString()], ["--"])
            options.noDetectIncludePath = true
            options.noLayoutTests = true

            let binding = generate(options)
            @Expect(binding.contains("marker_function"), true)
            @Expect(binding.contains("MarkerAlias"), true)
            @Expect(options.clangArgs.toArray(), ["--"])
        } finally {
            remove(directory, recursive: true)
        }
    }
}
