package cjbind.clang

import std.fs.Path
import std.process.{executeWithOutput, ProcessRedirect}
import std.io.{readString, ByteBuffer}
import std.collection.{collectArray, ArrayList, Map, HashMap}
import std.posix.{access, isReg, X_OK}
import glob

@When[os == "Linux"]
const OS = "Linux"
@When[os == "macOS"]
const OS = "macOS"
@When[os == "Windows"]
const OS = "Windows"
@When[os != "Windows"]
const EXE_SUFFIX = ""
@When[os == "Windows"]
const EXE_SUFFIX = ".exe"

@When[os == "Windows"]
func isExecutable(_: String): Bool {
    return true
}

@When[os != "Windows"]
func isExecutable(path: String): Bool {
    return access(path, X_OK) == 0
}

func run(bin: String, args: Array<String>, readStderr!: Bool = false, env!: Option<Map<String, String>> = None): ?String {
    try {
        let (_, out, err) = executeWithOutput(bin, args, stdIn: ProcessRedirect.Discard, environment: env)
        let buf = if (readStderr) {
            ByteBuffer(err)
        } else {
            ByteBuffer(out)
        }
        let s = readString(buf).trimAscii()
        return s
    } catch (e: Exception) {
        return None<String>
    }
}

func find(directory: String, patterns: Array<String>): ?Path {
    let dir = Path(glob.Pattern.escape(directory))

    for (pattern in patterns) {
        let p = dir.join(pattern).toString()

        try {
            let ret = glob.glob(p)
            for (p in ret) {
                let s = p.toString()
                if (isReg(s) && isExecutable(s)) {
                    return p
                }
            }
        } catch (e: glob.PatternException) {
            return None
        }
    }

    return None
}

func extractCCSearchPaths(path: String, args: Array<String>): ?Array<String> {
    let ccArgs = ArrayList<String>(["-E", "-x", "c", "-", "-v"])
    ccArgs.add(all: args)

    let env = HashMap(("LC_ALL", "C"))
    let output = if (let Some(v) <- run(path, ccArgs.toArray(), readStderr: true, env: env)) {
        v
    } else {
        return None
    }

    let start = if (let Some(i) <- output.indexOf("#include <...> search starts here:")) {
        i + 34
    } else {
        return None
    }

    let end = if (let Some(i) <- output.indexOf("End of search list.")) {
        i
    } else {
        return None
    }

    let rawPaths = output[start..end].replace("(framework directory)", "")

    let paths = rawPaths.lines().filter {l => !l.isEmpty()}.map {
        l => l.trimAscii()
    } |> collectArray

    return paths
}

public func getSearchPaths(args: Array<String>): Option<Array<String>> {
    // TODO: 手动解析 PATH
    if (let Some(v) <- extractCCSearchPaths("clang${EXE_SUFFIX}", args)) {
        return v
    }

    if (let Some(v) <- extractCCSearchPaths("gcc${EXE_SUFFIX}", args)) {
        return v
    }

    let paths = ArrayList<String>()

    if (let Some(v) <- run("llvm-config", ["--bindir"])) {
        if (let Some(line) <- v.lines().next()) {
            paths.add(line)
        }
    }

    if (OS == "macOS") {
        if (let Some(path) <- run("xcodebuild", ["-find", "clang"])) {
            if (let Some(line) <- path.lines().next()) {
                paths.add(line)
            }
        }
    }

    let default = "clang${EXE_SUFFIX}"
    let versioned = "clang-[0-9]*${EXE_SUFFIX}"
    let patterns = [default, versioned]

    var clang: ?Path = None

    for (path in paths) {
        if (let Some(c) <- find(path, patterns)) {
            clang = c
            break
        }
    }

    if (let Some(v) <- clang) {
        return extractCCSearchPaths(v.toString(), args)
    }

    eprintln("无法自动检测系统头文件导入路径，请手动设置搜索路径或者安装 clang/gcc")

    return None
}
