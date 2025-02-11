package cjbind.utils

public func sprintAlign(pre: Array<String>, post: Array<String>, insert!: String = "    "): String {
    if (pre.size != post.size) {
        throw Exception("pre and post should be of the same length")
    }

    if (pre.size == 0) {
        return ""
    }

    var preMaxLength = -1
    for (s in pre) {
        preMaxLength = max(s.size, preMaxLength)
    }

    let pad = preMaxLength + 3

    let ret = StringBuilder()

    for (i in 0..pre.size) {
        let preStr = pre[i].padEnd(pad)
        let postStr = post[i]
        ret.append(insert)
        ret.append(preStr)
        ret.append(postStr)
        ret.append("\n")
    }

    return ret.toString()
}