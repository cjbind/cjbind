package cjbind

import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.unittest.*
import std.unittest.testmacro.*

import cjbind.options.{CjbindOptions, DefaultAliasStyle, DefaultEnumStyle}

@Test
public class AliasAbiTest {
    @TestCase
    func enumNewtypesUseTheirIntegerAbiAtDirectValueBoundaries(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("enum_abi.h")
            File.writeTo(header, """
enum Mode { MODE_ZERO, MODE_ONE };
typedef enum Mode ModeAlias;
typedef enum Mode (*ModeCallback)(enum Mode value);
enum Mode mode_round_trip(enum Mode value);
ModeAlias mode_alias_round_trip(ModeAlias value);
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.defaultAliasStyle = DefaultAliasStyle.NewType
            options.defaultEnumStyle = DefaultEnumStyle.NewType
            options.clangArgs.add(all: [
                "-x", "c", "-std=gnu11", "--target=x86_64-w64-mingw32"
            ])

            let binding = generate(options)

            @Expect(binding.contains("foreign func mode_round_trip ( value: UInt32 ) : UInt32"), true)
            @Expect(binding.contains("return Mode(rawValue: mode_round_trip( value.rawValue ))"), true)
            @Expect(binding.contains("foreign func mode_alias_round_trip ( value: UInt32 ) : UInt32"), true)
            @Expect(binding.contains("value.rawValue.rawValue"), true)
            @Expect(binding.contains("ModeAlias(rawValue: Mode(rawValue:"), true)
            @Expect(binding.contains("CFunc<(value: UInt32) -> UInt32>"), true)
            @Expect(binding.contains("foreign func mode_round_trip ( value: Mode )"), false)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func newtypesRejectNonObjectOpaqueAndOveralignedTargets(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("alias_abi.h")
            File.writeTo(header, """
typedef __int128 WideAlias;
typedef int BareFunction(int);
struct Incomplete;
typedef struct Incomplete OpaqueAlias;
typedef int (*CallbackAlias)(int);
""".toArray())

            let options = CjbindOptions()
            options.headers.add(header.toString())
            options.noDetectIncludePath = true
            options.defaultAliasStyle = DefaultAliasStyle.NewType
            options.clangArgs.add(all: [
                "-x", "c", "-std=gnu11", "--target=x86_64-w64-mingw32"
            ])

            let binding = generate(options)

            @Expect(binding.contains("public struct WideAlias"), false)
            @Expect(binding.contains("public type WideAlias ="), true)
            @Expect(binding.contains("public struct BareFunction"), false)
            @Expect(binding.contains("public type BareFunction ="), true)
            @Expect(binding.contains("public struct OpaqueAlias"), false)
            @Expect(binding.contains("public struct CallbackAlias"), true)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
