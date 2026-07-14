package cjbind.ir

import std.unittest.*
import std.unittest.testmacro.*
import cjbind.clang.CommentAttribute

func annotationAttribute(name: String, value!: String = ""): CommentAttribute {
    return CommentAttribute(name, value)
}

func parsedAnnotationAttributes(attributes: Array<CommentAttribute>): Annotations {
    return parseAnnotationAttributes(attributes).getOrThrow()
}

@Test
public class AnnotationParsingTest {
    @TestCase
    func parsesCangjieBindingControlAttributes(): Unit {
        let annotations = parsedAnnotationAttributes([
            annotationAttribute("cjbind"),
            annotationAttribute("opaque"),
            annotationAttribute("hide")
        ])

        @Expect(annotations.opaque(), true)
        @Expect(annotations.hide(), true)
    }

    @TestCase
    func parsesEnumVariantHideAttribute(): Unit {
        let annotations = parsedAnnotationAttributes([
            annotationAttribute("cjbind"),
            annotationAttribute("hide")
        ])

        @Expect(annotations.hide(), true)
        @Expect(annotations.opaque(), false)
    }

    @TestCase
    func requiresMarkerAsTheFirstAttribute(): Unit {
        @Expect(parseAnnotationAttributes([
            annotationAttribute("opaque"),
            annotationAttribute("cjbind")
        ]).isNone(), true)
        @Expect(parseAnnotationAttributes(Array<CommentAttribute>()).isNone(), true)
    }

}
