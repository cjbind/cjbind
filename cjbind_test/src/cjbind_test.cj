package cjbind_test

import std.fs.Path
import std.collection.collectArray
import std.unittest.*
import std.unittest.testmacro.{TestBuilder, Assert}
import glob

func searchTestCases(): Array<String> {
    let testdataDir = Path(glob.Pattern.escape("testdata"))
    let pattern = testdataDir.join("**/*.h").toString()
    let paths = glob.glob(pattern)
    return paths.map { p => p.toString() } |> collectArray
}

@TestBuilder
public func buildOutputTestSuite(): TestSuite {
   let suiteBuilder = TestSuite.builder("Output")
   let caseConfiguration = Configuration()
   suiteBuilder.add(
       UnitTestCase.createParameterized("Test cjbind output", [1, 2]) { value => @Assert( value >= 1 ) })
   suiteBuilder.build()
}