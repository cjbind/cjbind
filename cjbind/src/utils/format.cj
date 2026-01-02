package cjbind.utils

import std.env
import std.process.executeWithOutput
import std.fs.{Directory, File, remove}

public func formatString(f: String): String {
    let tmpDir = Directory.createTemp(env.getTempDirectory())

    let temp = tmpDir.join("cjbind.cj")
    File.writeTo(temp, f.toArray())

    try {
        let (code, _, _) = executeWithOutput("cjfmt", ["-f", temp.toString()])
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
