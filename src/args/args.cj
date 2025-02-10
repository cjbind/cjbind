package cjbind.args

import std.collection.{ArrayList, HashMap}
import std.console

public interface Flag {
    func read(_: Iterator<String>): Unit {}

    func help(): String

    func shortArg(): ?String {
        return None
    }

    func longArg(): String
}

public class StringFlag <: Flag {
    private var value: ?String
    private let shortFlag: ?String
    private let longFlag: String
    private let name: String
    private let helpContent: String

    init(defaultValue: ?String, shortFlag: ?String, longFlag: String, name: String, helpContent: String) {
        this.value = defaultValue
        this.shortFlag = shortFlag
        this.longFlag = longFlag
        this.name = name
        this.helpContent = helpContent
    }

    public func read(it: Iterator<String>): Unit {
        this.value = match (it.next()) {
            case Some(v) => v
            case None => throw Exception("选项 ${name} 需要参数")
        }
    }

    public func help(): String {
        return this.helpContent
    }

    public func shortArg(): ?String {
        return this.shortFlag
    }

    public func longArg(): String {
        return this.longFlag
    }
}

public class BoolFlag <: Flag {
    private var value: Bool
    private let shortFlag: ?String
    private let longFlag: String
    private let name: String
    private let helpContent: String

    init(value: Bool, shortFlag: ?String, longFlag: String, name: String, helpContent: String) {
        this.value = value
        this.shortFlag = shortFlag
        this.longFlag = longFlag
        this.name = name
        this.helpContent = helpContent
    }

    public func read(_: Iterator<String>): Unit {
        this.value = true
    }

    public func help(): String {
        return this.helpContent
    }

    public func shortArg(): ?String {
        return this.shortFlag
    }

    public func longArg(): String {
        return this.longFlag
    }
}

class ArgsParser {
    private let args: ArrayList<Flag>

    private let shortMap: HashMap<String, Flag>
    private let longMap: HashMap<String, Flag>

    public init(input: ArrayList<Flag>) {
        this.shortMap = HashMap<String, Flag>()
        this.longMap = HashMap<String, Flag>()
        this.args = input

        for (a in input) {
            if (let Some(v) <- a.shortArg()) {
                if (shortMap.contains(v)) {
                    throw Exception("短选项 ${v} 重复")
                }
                shortMap.add(v, a)
            }
            let lv = a.longArg()
            if (longMap.contains(lv)) {
                throw Exception("长选项 ${lv} 重复")
            }
            longMap.add(lv, a)
        }
    }

    public func parse(input: Array<String>): Unit {
        let it = input.iterator()
        for (i in it) {}
    }
}
