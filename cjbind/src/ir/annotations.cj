package cjbind.ir

import cjbind.clang

class Annotations {
    private var opaqueValue = false
    private var hideValue = false

    func opaque(): Bool {
        return this.opaqueValue
    }

    func hide(): Bool {
        return this.hideValue
    }

    func apply(attributes: Array<clang.CommentAttribute>): Unit {
        for (attribute in attributes) {
            match (attribute.name) {
                case "opaque" => this.opaqueValue = true
                case "hide" => this.hideValue = true
                case _ => ()
            }
        }
    }
}

func isAnnotationElement(attributes: Array<clang.CommentAttribute>): Bool {
    return !attributes.isEmpty() && attributes[0].name == "cjbind"
}

func parseAnnotationComment(comment: clang.Comment, annotations: Annotations): Bool {
    var matched = false
    if (comment.kind() == clang.CXCommentKind_CXComment_HTMLStartTag) {
        match (comment.tagName()) {
            case Some(tagName) =>
                let attributes = comment.attrs()
                if (tagName == "div" && isAnnotationElement(attributes)) {
                    annotations.apply(attributes)
                    matched = true
                }
            case None => ()
        }
    }

    for (child in comment.children()) {
        if (parseAnnotationComment(child, annotations)) {
            matched = true
        }
    }
    return matched
}

func parseAnnotations(comment: clang.Comment): ?Annotations {
    let annotations = Annotations()
    if (parseAnnotationComment(comment, annotations)) {
        return Some(annotations)
    }
    return None
}

func parseAnnotationAttributes(attributes: Array<clang.CommentAttribute>): ?Annotations {
    if (!isAnnotationElement(attributes)) {
        return None
    }
    let annotations = Annotations()
    annotations.apply(attributes)
    return Some(annotations)
}
