package build

import std.process.Process
import std.fs.{Path, exists, copy, removeIfExists}
import std.io.{readString, ByteBuffer}
import std.collection.ArrayList
import glob.{globWith, MatchOptions}

main(): Int64 {
    match (Process.current.arguments[0]) {
        case "pre-build" => stagePreBuild()
        case "pre-clean" => stagePreClean()
        case _ => 0
    }
}

@When[os == "Linux" || os == "macOS"]
const DLL_PREFIX = "lib"
@When[os == "Windows"]
const DLL_PREFIX = ""
@When[os == "Linux"]
const DLL_SUFFIX = ".so"
@When[os == "macOS"]
const DLL_SUFFIX = ".dylib"
@When[os == "Windows"]
const DLL_SUFFIX = ".dll"
@When[os == "Linux"]
const OS = "Linux"
@When[os == "macOS"]
const OS = "macOS"
@When[os == "Windows"]
const OS = "Windows"
let DIRS_LINUX = [
    "/usr/local/llvm*/lib*",
    "/usr/local/lib*/*/*",
    "/usr/local/lib*/*",
    "/usr/local/lib*",
    "/usr/lib*/*/*",
    "/usr/lib*/*",
    "/usr/lib*"
]
let DIRS_MACOS = [
    "/usr/local/opt/llvm*/lib/llvm*/lib",
    "/Library/Developer/CommandLineTools/usr/lib",
    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib",
    "/usr/local/opt/llvm*/lib"
]
let DIRS_WINDOWS = ["C:\\MSYS*\\MinGW*\\lib", "C:\\MSYS*\\clang*\\lib"]

func runLLVMConfig() {
    try {
        let (_, out, _) = Process.runOutput("llvm-config", ["--prefix"])
        let buf = ByteBuffer(out)
        let s = readString(buf).trimAscii()
        return s
    } catch (e: Exception) {
        return None<String>
    }
}

func xcodeSelect() {
    try {
        let (_, out, _) = Process.runOutput("xcode-select", ["--print-path"])
        let buf = ByteBuffer(out)
        let s = readString(buf).trimAscii()
        return s
    } catch (e: Exception) {
        return None<String>
    }
}

// cjlint-ignore -start !G.FUN.01 fun
func searchClang(): Option<String> {
    let dirs = ArrayList<String>(
        match (OS) {
            case "Linux" => DIRS_LINUX
            case "macOS" => DIRS_MACOS
            case "Windows" => DIRS_WINDOWS
            case _ => throw Exception("Unsupported OS")
        })

    let files = ArrayList<String>(["${DLL_PREFIX}clang${DLL_SUFFIX}"])

    match (OS) {
        case "Linux" =>
            files.add("libclang-*.so")
            files.add("libclang.so.*")
            files.add("libclang-*.so.*")
        case "Windows" => files.add("libclang.dll")
        case _ => ()
    }

    let search: (String) -> Option<Path> = {
        d: String =>
        var options = MatchOptions()
        options.requireLiteralSeparator = true
        for (f in files) {
            let p = globWith("${d}/${f}", options)
            for (bin in p) {
                if (bin.fileName.contains("-cpp.")) {
                    continue
                }
                return Some(bin)
            }
        }
        return None<Path>
    }

    let search_dir: (String) -> Option<Path> = {
        d: String =>
        if (let Some(b) <- search(d)) {
            return Some(b)
        }

        if (OS == "Windows") {
            if (d.endsWith("lib")) {
                let p = Path(d)
                let n = p.join("bin").toString()
                return search(n)
            }
        }

        return None<Path>
    }

    if (OS == "macOS") {
        if (let Some(base) <- xcodeSelect()) {
            let pb = Path(base)
            dirs.add(pb.join("Toolchains/XcodeDefault.xctoolchain/usr/lib").toString(), at: 0)
        }
    }

    if (let Some(base) <- runLLVMConfig()) {
        let pb = Path(base)
        dirs.add(pb.join("bin").toString(), at: 0)
        dirs.add(pb.join("lib").toString(), at: 0)
        dirs.add(pb.join("lib64").toString(), at: 0)
    }

    for (d in dirs) {
        if (let Some(b) <- search_dir(d)) {
            return Some(b.toString())
        }
    }

    return None
}
// cjlint-ignore -end fun

var STUB_CLANG_LIB = Path("./lib/libclang${DLL_SUFFIX}")
var CLANG_STATIC_LIB = Path("./lib/libclang.a")

func missingLib() {
    return !exists(STUB_CLANG_LIB) && !exists(CLANG_STATIC_LIB)
}

func stagePreBuild(): Int64 {
    if (missingLib()) {
        match (searchClang()) {
            case Some(clang) => copy(Path(clang), to: STUB_CLANG_LIB)

            case None => throw Exception("Clang not found")
        }
    }

    return 0
}

func stagePreClean(): Int64 {
    removeIfExists(STUB_CLANG_LIB)

    return 0
}
