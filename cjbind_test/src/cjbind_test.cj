package cjbind_test

import std.fs.{File, Path, exists}
import std.collection.collectArray
import std.unittest.*
import std.unittest.testmacro.{TestBuilder, Assert}
import glob
import cjbind.{generate}
import cjbind.options.{CjbindOptions, DefaultEnumStyle}
import cjbind.utils.formatString
import std.env.getCommandLine

let testdataDir: String = if (exists("cjbind_test/testdata")) {
    "cjbind_test/testdata"
} else {
    "testdata"
}

func searchTestCases(): Array<String> {
    let paths = glob.glob("${testdataDir}/headers/*.h")
    return paths.map {p => p.toString()} |> collectArray
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

func generateOutput(testcase: String): String {
    let opt = CjbindOptions()
    opt.headers.add(testcase)
    opt.noDetectIncludePath = true
    applyTestOptions(opt, testcase)
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
    let shouldUpdate = args.any { arg: String => arg == "update" }

    if (shouldUpdate) {
        File.writeTo(expectedPath, output.toArray())
    } else {
        let expected = String.fromUtf8(File.readFrom(expectedPath))
        @Assert(output, expected)
    }
}

@TestBuilder
public func buildOutputTestSuite(): TestSuite {
    let testcases = searchTestCases()

    let suiteBuilder = TestSuite.builder("Output")
    suiteBuilder.add(UnitTestCase.createParameterized("Test cjbind output", testcases, body: processTestCase))
    suiteBuilder.build()
}
