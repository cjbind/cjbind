package cjbind.utils

import std.process.Process
import std.fs.{Directory, File, remove}

public func formatString(f: String): String {
    let tmpDir = Directory.createTemp(Process.current.tempDirectory)

    let temp = tmpDir.join("cjbind.cj")
    File.writeTo(temp, f.toArray())

    try {
        let (code, _, _) = Process.runOutput("cjfmt", ["-f", temp.toString()])
        if (code != 0) {
            throw Exception("cjfmt 失败")
        }
    } catch (e: Exception) {
        eprintln("cjfmt 失败: ${e.toString()}")
        return f
    }

    let out = String.fromUtf8(File.readFrom(temp))

    remove(tmpDir, recursive: true)

    return out
}
