package cjbind.arg

import std.collection.{ArrayList, HashMap}
import cjbind.utils.sprintAlign

public abstract class Flag {
    public func read(_: Iterator<String>): Unit

    public let shortArg: ?String
    public let longArg: String
    public let name: String
    public let description: String
    public let optSuffix: ?String

    public init(shortArg: ?String, longArg: String, name: String, description: String, optSuffix: ?String) {
        this.shortArg = shortArg
        this.longArg = longArg
        this.name = name
        this.description = description
        this.optSuffix = optSuffix
    }

    public func getHelp(): (String, String) {
        let opt = if (let Some(v) <- this.shortArg) {
            "-${v}, --${this.longArg}"
        } else {
            "    --${this.longArg}"
        } + if (let Some(v) <- optSuffix) {
            " <${v}>"
        } else {
            ""
        }

        return (opt, this.description)
    }
}

public class StringFlag <: Flag {
    public var value: ?String = None

    public init(shortArg: ?String, longArg: String, name: String, description: String, optSuffix: ?String, defaultValue: ?String) {
        super(shortArg, longArg, name, description, optSuffix)
        this.value = defaultValue
    }

    public func read(it: Iterator<String>): Unit {
        match (it.next()) {
            case Some(v) => value = v
            case None => throw Exception("选项 ${this.name} 需要一个参数")
        }
    }

}

public class BoolFlag <: Flag {
    public var value: Bool = false

    public init(shortArg: ?String, longArg: String, name: String, description: String) {
        super(shortArg, longArg, name, description, None)
    }

    public func read(_: Iterator<String>): Unit {
        this.value = true
    }
}

public class ArgsParser {
    private let args: Array<Flag>

    private let shortMap: HashMap<String, Flag> = HashMap()
    private let longMap: HashMap<String, Flag> = HashMap()
    private let nameMap: HashMap<String, Flag> = HashMap()

    public init(input: Array<Flag>) {
        this.args = input

        for (a in input) {
            if (let Some(v) <- a.shortArg) {
                if (shortMap.contains(v)) {
                    throw Exception("短选项 ${v} 重复")
                }
                shortMap.add(v, a)
            }
            let lv = a.longArg
            if (longMap.contains(lv)) {
                throw Exception("长选项 ${lv} 重复")
            }
            longMap.add(lv, a)
            nameMap.add(a.name, a)
        }
    }

    public func parse(input: Array<String>): (Array<String>, Array<String>) {
        let it = input.iterator()

        // remove bin
        it.next()
        
        let headers = ArrayList<String>()
        var collectingClangArgs = false
        let clangArgs = ArrayList<String>()

        for (i in it) {
            if (i == "--") {
                collectingClangArgs = true
                continue
            }

            if (collectingClangArgs) {
                clangArgs.add(i)
                continue
            }

            if (i.startsWith("--")) {
                let body = i[2..]
                let flag = match (longMap.get(body)) {
                    case Some(v) => v
                    case None => throw Exception("未知选项 ${i}")
                }
                flag.read(it)
            } else if (i.startsWith("-")) {
                let body = i[1..]
                let flag = match (shortMap.get(body)) {
                    case Some(v) => v
                    case None => throw Exception("未知选项 ${i}")
                }
                flag.read(it)
            } else {
                headers.add(i)
            }
        }

        return (headers.toArray(), clangArgs.toArray())
    }

    public func getHelp(): String {
        let sb = StringBuilder()

        let header = """
自动生成仓颉到 C 库的 FFI 绑定代码。

用法：cjbind <OPTIONS> <HEADER> -- <CLANG_ARGS>

参数：
    <HEADER>          C 头文件路径
    [CLANG_ARGS]...   会被直接传递给 clang 的参数

选项：
"""
        sb.append(header)
        let pres = Array<String>(args.size, repeat: "")
        let posts = Array<String>(args.size, repeat: "")

        for (i in 0..args.size) {
            let arg = args[i]
            let (pre, post) = arg.getHelp()
            pres[i] = pre
            posts[i] = post
        }

        let options = sprintAlign(pres, posts)
        sb.append(options)

        return sb.toString()
    }
}
