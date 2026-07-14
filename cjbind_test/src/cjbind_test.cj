package cjbind_test

import std.fs.{File, Path, exists}
import std.collection.ArrayList
import std.unittest.*
import std.unittest.testmacro.{TestBuilder, Assert}
import glob
import cjbind.{generate}
import cjbind.options.{
    CjbindOptions,
    ConfiguredCanDerive,
    ConfiguredDeriveTrait,
    DefaultEnumStyle,
    FieldInfo
}
import cjbind.utils.formatString
import std.env.{getCommandLine, getVariable}

let testdataDir: String = if (exists("cjbind_test/testdata")) {
    "cjbind_test/testdata"
} else {
    "testdata"
}

func searchTestCases(): Array<String> {
    let paths = ArrayList<String>()
    let filter = getVariable("CJBIND_TEST_FILTER")
    for (extension in ["h", "H", "hpp", "hxx", "hh", "h++"]) {
        for (path in glob.glob("${testdataDir}/headers/*.${extension}")) {
            let pathString = path.toString()
            if (filter.map({value => pathString.contains(value)}).getOrDefault({=> true})) {
                paths.add(pathString)
            }
        }
    }
    return paths.toArray()
}

func applyTestOptions(opt: CjbindOptions, testcase: String): Unit {
    let content = String.fromUtf8(File.readFrom(Path(testcase)))
    for (line in content.split("\n")) {
        let trimmed = line.trimAscii()
        if (trimmed.startsWith("// cjbind-options:")) {
            let optsStr = trimmed["// cjbind-options:".size..].trimAscii()
            let parts = optsStr.split(" ", removeEmpty: true)
            var i = 0
            while (i < parts.size) {
                let part = parts[i].trimAscii()
                if (part == "--default-enum-style" && i + 1 < parts.size) {
                    opt.defaultEnumStyle = match (parts[i + 1].trimAscii()) {
                        case "newtype" => DefaultEnumStyle.NewType
                        case _ => DefaultEnumStyle.Consts
                    }
                    i += 2
                } else if (part == "--objc") {
                    opt.objc = true
                    i += 1
                } else if (part == "--no-enum-prefix") {
                    opt.noEnumPrefix = true
                    i += 1
                } else if (part == "--fit-macro-constants") {
                    opt.fitMacroConstants = true
                    i += 1
                } else if (part == "--no-union-accessor-workaround") {
                    opt.useUnionAccessorWorkaround = false
                    i += 1
                } else if (part == "--auto-cstring") {
                    opt.autoCString = true
                    i += 1
                } else if (part == "--enable-cxx-namespaces") {
                    opt.enableCxxNamespaces = true
                    i += 1
                } else if (part == "--conservative-inline-namespaces") {
                    opt.conservativeInlineNamespaces = true
                    i += 1
                } else if (part == "--ignore-methods") {
                    opt.generateMethods = false
                    i += 1
                } else if (part == "--generate" && i + 1 < parts.size) {
                    opt.generateFunctions = false
                    opt.generateTypes = false
                    opt.generateVars = false
                    opt.generateMethods = false
                    opt.generateConstructors = false
                    opt.generateDestructors = false
                    for (item in parts[i + 1].trimAscii().split(",")) {
                        match (item.trimAscii()) {
                            case "methods" => opt.generateMethods = true
                            case "constructors" => opt.generateConstructors = true
                            case "destructors" => opt.generateDestructors = true
                            case "functions" => opt.generateFunctions = true
                            case "types" => opt.generateTypes = true
                            case "vars" => opt.generateVars = true
                            case value => eprintln("Warning: unrecognized generation item: ${value}")
                        }
                    }
                    i += 2
                } else if (part == "--represent-cxx-operators") {
                    opt.representCxxOperators = true
                    i += 1
                } else if (part == "--respect-cxx-access-specs") {
                    opt.respectCxxAccessSpecs = true
                    i += 1
                } else if (part == "--use-specific-virtual-function-receiver") {
                    opt.useSpecificVirtualFunctionReceiver = true
                    i += 1
                } else if (part == "--use-distinct-char16-t") {
                    opt.useDistinctChar16T = true
                    i += 1
                } else if (part == "--generate-inline-functions") {
                    opt.generateInlineFunctions = true
                    i += 1
                } else if (part == "--generate-deleted-functions") {
                    opt.generateDeletedFunctions = true
                    i += 1
                } else if (part == "--generate-pure-virtual-functions") {
                    opt.generatePureVirtualFunctions = true
                    i += 1
                } else if (part == "--generate-private-functions") {
                    opt.generatePrivateFunctions = true
                    i += 1
                } else if (part == "--vtable-generation") {
                    opt.vtableGeneration = true
                    i += 1
                } else if (part == "--blocklist-type" && i + 1 < parts.size) {
                    opt.blocklistedTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--blocklist-function" && i + 1 < parts.size) {
                    opt.blocklistedFunctions.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--blocklist-item" && i + 1 < parts.size) {
                    opt.blocklistedItems.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--blocklist-var" && i + 1 < parts.size) {
                    opt.blocklistedVars.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--blocklist-file" && i + 1 < parts.size) {
                    opt.blocklistedFiles.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--opaque-type" && i + 1 < parts.size) {
                    opt.opaqueTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--allowlist-type" && i + 1 < parts.size) {
                    opt.allowlistedTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--allowlist-function" && i + 1 < parts.size) {
                    opt.allowlistedFunctions.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--allowlist-item" && i + 1 < parts.size) {
                    opt.allowlistedItems.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--allowlist-var" && i + 1 < parts.size) {
                    opt.allowlistedVars.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--allowlist-file" && i + 1 < parts.size) {
                    opt.allowlistedFiles.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--no-recursive-allowlist") {
                    opt.allowlistRecursively = false
                    i += 1
                } else if (part == "--no-record-matches") {
                    opt.recordMatches = false
                    i += 1
                } else if (part == "--disable-untagged-union") {
                    opt.untaggedUnion = false
                    i += 1
                } else if (part == "--no-size_t-is-usize") {
                    opt.sizeTIsUsize = false
                    i += 1
                } else if (part == "--no-derive-copy") {
                    opt.deriveCopy = false
                    i += 1
                } else if (part == "--no-derive-debug") {
                    opt.deriveDebug = false
                    i += 1
                } else if (part == "--with-derive-default") {
                    opt.deriveDefault = true
                    i += 1
                } else if (part == "--no-derive-default") {
                    opt.deriveDefault = false
                    i += 1
                } else if (part == "--with-derive-hash") {
                    opt.deriveHash = true
                    i += 1
                } else if (part == "--with-derive-partialeq") {
                    opt.derivePartialEq = true
                    i += 1
                } else if (part == "--with-derive-eq") {
                    opt.deriveEq = true
                    i += 1
                } else if (part == "--with-derive-partialord") {
                    opt.derivePartialOrd = true
                    i += 1
                } else if (part == "--with-derive-ord") {
                    opt.deriveOrd = true
                    i += 1
                } else if (part == "--impl-debug") {
                    opt.implDebug = true
                    i += 1
                } else if (part == "--impl-partialeq") {
                    opt.implPartialEq = true
                    i += 1
                } else if (part == "--blocklisted-traits-manually") {
                    opt.blocklistedTypeImplementsTraitCallback = Some({
                        _: String, _: ConfiguredDeriveTrait =>
                            Some(ConfiguredCanDerive.Manually)
                    })
                    i += 1
                } else if (part == "--blocklisted-traits-yes") {
                    opt.blocklistedTypeImplementsTraitCallback = Some({
                        _: String, _: ConfiguredDeriveTrait =>
                            Some(ConfiguredCanDerive.Yes)
                    })
                    i += 1
                } else if (part == "--no-copy" && i + 1 < parts.size) {
                    opt.noCopyTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--no-debug" && i + 1 < parts.size) {
                    opt.noDebugTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--no-default" && i + 1 < parts.size) {
                    opt.noDefaultTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--no-hash" && i + 1 < parts.size) {
                    opt.noHashTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--no-partialeq" && i + 1 < parts.size) {
                    opt.noPartialEqTypes.add(parts[i + 1].trimAscii())
                    i += 2
                } else if (part == "--field-rename-callback") {
                    opt.fieldNameCallback = {
                        info: FieldInfo =>
                        if (info.typeName != "RenameMe_RenameMe") {
                            return None
                        }
                        return match (info.fieldName) {
                            case "renamed_member" => Some("cj_friendly")
                            case "bitfield_uGlyName" => Some("bitfield_less_ugly_name")
                            case "bitfieldWorse_name" => Some("bitfield_better_name")
                            case _ => None
                        }
                    }
                    i += 1
                } else if (part == "--clang-arg" && i + 1 < parts.size) {
                    opt.clangArgs.add(parts[i + 1].trimAscii())
                    i += 2
                } else {
                    eprintln("Warning: unrecognized test option: ${part}")
                    i += 1
                }
            }
        }
    }
}

let defaultTarget = "--target=x86_64-unknown-linux-gnu"

func hasTargetFlag(opt: CjbindOptions): Bool {
    for (arg in opt.clangArgs) {
        if (arg.startsWith("--target=")) {
            return true
        }
    }
    return false
}

func generateOutput(testcase: String): String {
    let opt = CjbindOptions()
    opt.headers.add(testcase)
    opt.noDetectIncludePath = true
    applyTestOptions(opt, testcase)
    // Pin to a default target so that expected outputs are platform-independent.
    if (!hasTargetFlag(opt)) {
        opt.clangArgs.add(defaultTarget)
    }
    return formatString(generate(opt))
}

// 如果 args 中有 update，则更新 testcase 的输出
// 否则比较 testcase 的输出和 expected 文件
// 输出应该在 testcase 目录下的 expected 目录中
func processTestCase(testcase: String): Unit {
    let headerPath = Path(testcase)
    let headerName = headerPath.fileName.toString()
    let output = generateOutput(testcase)

    var dotIdx = headerName.size
    var di = headerName.size - 1
    while (di >= 0) {
        if (headerName[di] == 46u8) {
            dotIdx = di
            break
        }
        di -= 1
    }
    let baseName = headerName[0..dotIdx]
    let expectedPath = Path("${testdataDir}/expected/${baseName}.cj")

    let args = getCommandLine()
    let shouldUpdate = getVariable("CJBIND_UPDATE_EXPECTED").isSome() || args.any { arg: String => arg == "update" }

    let normalizedOutput = output.replace("\r\n", "\n")

    if (shouldUpdate) {
        File.writeTo(expectedPath, normalizedOutput.toArray())
    } else {
        let expected = String.fromUtf8(File.readFrom(expectedPath)).replace("\r\n", "\n")
        @Assert(normalizedOutput, expected)
    }
}

@TestBuilder
public func buildOutputTestSuite(): TestSuite {
    let testcases = searchTestCases()

    let suiteBuilder = TestSuite.builder("Output")
    suiteBuilder.add(UnitTestCase.createParameterized("Test cjbind output", testcases, body: processTestCase))
    suiteBuilder.build()
}
