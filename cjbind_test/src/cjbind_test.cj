package cjbind_test

import std.fs.{File, Path, exists}
import std.collection.ArrayList
import std.unittest.*
import std.unittest.testmacro.{TestBuilder, Assert}
import glob
import cjbind.{generate}
import cjbind.options.{CjbindOptions, DefaultEnumStyle, DefaultAliasStyle, FieldInfo}
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

func testOptionValue(
    parts: Array<String>,
    index: Int64,
    option: String,
    testcase: String
): String {
    let valueIndex = index + 1
    if (valueIndex >= parts.size || parts[valueIndex] == "--" || parts[valueIndex].startsWith("--")) {
        throw Exception("${testcase}: missing value for test option '${option}'")
    }
    return parts[valueIndex].trimAscii()
}

func configureStructFieldRenameCallback(opt: CjbindOptions): Unit {
    opt.fieldNameCallback = {
        info: FieldInfo =>
            if (info.typeName != "RenameMe") {
                return None
            }
            if (info.fieldTypeName == Some("char")) {
                return Some("char_${info.fieldName}")
            }
            return match (info.fieldName) {
                case "renamed_member" => Some("rust_friendly")
                case "bitfield_uGlyName" => Some("bitfield_less_ugly_name")
                case "bitfieldWorse_name" => Some("bitfield_better_name")
                case _ => None
            }
    }
}

func applyTestParseCallback(opt: CjbindOptions, callback: String, testcase: String): Unit {
    match (callback) {
        case "struct-field-rename" => configureStructFieldRenameCallback(opt)
        case "" => throw Exception("${testcase}: missing cjbind parse callback name")
        case _ => throw Exception("${testcase}: unknown cjbind parse callback '${callback}'")
    }
}

func applyTestOptionLine(opt: CjbindOptions, optsStr: String, testcase: String): Unit {
    let parts = optsStr.split(" ", removeEmpty: true)
    if (parts.isEmpty()) {
        throw Exception("${testcase}: missing cjbind test option")
    }
    var i = 0
    while (i < parts.size) {
        let part = parts[i].trimAscii()
        if (part == "--") {
            if (i + 1 >= parts.size) {
                throw Exception("${testcase}: missing Clang arguments after '--'")
            }
            i += 1
            while (i < parts.size) {
                opt.clangArgs.add(parts[i].trimAscii())
                i += 1
            }
        } else if (part == "--default-enum-style") {
            let value = testOptionValue(parts, i, part, testcase)
            opt.defaultEnumStyle = match (value) {
                case "newtype" => DefaultEnumStyle.NewType
                case "consts" => DefaultEnumStyle.Consts
                case _ => throw Exception("${testcase}: invalid value '${value}' for test option '${part}'")
            }
            i += 2
        } else if (part == "--default-alias-style") {
            let value = testOptionValue(parts, i, part, testcase)
            opt.defaultAliasStyle = match (value) {
                case "type_alias" => DefaultAliasStyle.TypeAlias
                case "new_type" => DefaultAliasStyle.NewType
                case "new_type_deref" => DefaultAliasStyle.NewTypeDeref
                case _ => throw Exception("${testcase}: invalid value '${value}' for test option '${part}'")
            }
            i += 2
        } else if (part == "--type-alias") {
            opt.typeAliases.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--new-type-alias") {
            opt.newTypeAliases.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--new-type-alias-deref") {
            opt.newTypeDerefAliases.add(testOptionValue(parts, i, part, testcase))
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
        } else if (part == "--generate") {
            let value = testOptionValue(parts, i, part, testcase)
            opt.generateFunctions = false
            opt.generateTypes = false
            opt.generateVars = false
            opt.generateMethods = false
            opt.generateConstructors = false
            opt.generateDestructors = false
            for (item in value.split(",")) {
                match (item.trimAscii()) {
                    case "methods" => opt.generateMethods = true
                    case "constructors" => opt.generateConstructors = true
                    case "destructors" => opt.generateDestructors = true
                    case "functions" => opt.generateFunctions = true
                    case "types" => opt.generateTypes = true
                    case "vars" => opt.generateVars = true
                    case invalid => throw Exception("${testcase}: invalid generation item '${invalid}'")
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
        } else if (part == "--blocklist-type") {
            opt.blocklistedTypes.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--blocklist-function") {
            opt.blocklistedFunctions.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--blocklist-item") {
            opt.blocklistedItems.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--blocklist-var") {
            opt.blocklistedVars.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--blocklist-file") {
            opt.blocklistedFiles.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--opaque-type") {
            opt.opaqueTypes.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--allowlist-type") {
            opt.allowlistedTypes.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--allowlist-function") {
            opt.allowlistedFunctions.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--allowlist-item") {
            opt.allowlistedItems.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--allowlist-var") {
            opt.allowlistedVars.add(testOptionValue(parts, i, part, testcase))
            i += 2
        } else if (part == "--allowlist-file") {
            opt.allowlistedFiles.add(testOptionValue(parts, i, part, testcase))
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
        } else {
            throw Exception("${testcase}: unknown test option '${part}'")
        }
    }
}

func applyTestOptions(opt: CjbindOptions, testcase: String): Unit {
    let content = String.fromUtf8(File.readFrom(Path(testcase)))
    for (line in content.split("\n")) {
        let trimmed = line.trimAscii()
        if (trimmed.startsWith("// cjbind-options:")) {
            let optsStr = trimmed["// cjbind-options:".size..].trimAscii()
            applyTestOptionLine(opt, optsStr, testcase)
        } else if (trimmed.startsWith("// cjbind-parse-callbacks:")) {
            let callback = trimmed["// cjbind-parse-callbacks:".size..].trimAscii()
            applyTestParseCallback(opt, callback, testcase)
        } else if (trimmed.startsWith("// cjbind-options") || trimmed.startsWith("// cjbind-parse-callbacks")) {
            throw Exception("${testcase}: malformed cjbind test directive '${trimmed}'")
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
    let shouldUpdate = getVariable("CJBIND_UPDATE_EXPECTED").isSome() || args.any {arg: String => arg == "update"}

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
