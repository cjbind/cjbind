package cjbind_test

import std.fs.{File, Path}
import std.collection.collectArray
import std.unittest.*
import std.unittest.testmacro.{TestBuilder, Assert}
import glob
import cjbind.{generate}
import cjbind.options.CjbindOptions
import cjbind.utils.formatString
import std.env.{getCommandLine}

func searchTestCases(): Array<String> {
    let testdataDir = glob.Pattern.escape("testdata/headers/*.h")
    let paths = glob.glob(testdataDir)
    return paths.map {p => p.toString()} |> collectArray
}

func generateOutput(testcase: String): String {
    let opt = CjbindOptions()
    opt.headers.add(testcase)
    return formatString(generate(opt))
}

// 如果 args 中有 update，则更新 testcase 的输出
// 否则比较 testcase 的输出和 expected 文件
// 输出应该在 testcase 目录下的 expected 目录中
func processTestCase(testcase: String): Unit {
    let output = generateOutput(testcase)

    let headerPath = Path(testcase)
    let headerName = headerPath.fileName.toString()
    let baseName = headerName[0..(headerName.size - 2)]
    let expectedPath = Path("testdata/expected/${baseName}.cj")

    let args = getCommandLine()
    let shouldUpdate = args.any { arg => arg == "update" }

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
    let caseConfiguration = Configuration()
    suiteBuilder.add(UnitTestCase.createParameterized("Test cjbind output", testcases, body: processTestCase))
    suiteBuilder.build()
}
