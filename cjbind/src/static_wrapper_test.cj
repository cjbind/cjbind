package cjbind

import std.env.getTempDirectory
import std.fs.{Directory, File, remove}
import std.process.executeWithOutput
import std.unittest.*
import std.unittest.testmacro.*

import cjbind.options.CjbindOptions

func staticWrapperOptions(header: String, output: String): CjbindOptions {
    let options = CjbindOptions()
    options.headers.add(header)
    options.noDetectIncludePath = true
    options.wrapStaticFns = true
    options.wrapStaticFnsPath = Some(output)
    return options
}

@Test
public class StaticFunctionWrapperTest {
    @TestCase
    func emitsAndCompilesCBridgeSource(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("static_functions.h")
            File.writeTo(header, """
typedef int (*callback_t)(int);
typedef int (*old_style_callback_t)();
typedef struct { int value; } anonymous_record_t;
typedef enum { ANONYMOUS_ZERO = 0, ANONYMOUS_ONE = 1 } anonymous_enum_t;
typedef struct { float _Complex value; } complex_record_t;
typedef struct { _Float16 value; } half_record_t;
typedef struct { half_record_t nested; } nested_half_record_t;
typedef union { double value; } double_union_t;
typedef struct { unsigned value : 3; } bitfield_record_t;

static const _Float16 unsupported_half_constant = 1.0;

struct named_record { int value; };
typedef struct named_record *named_record;

static inline int apply(callback_t callback, const int value) {
    return callback(value);
}

static inline int invoke_old_style(old_style_callback_t callback) {
    return callback();
}

static void reset(int *value) {
    *value = 0;
}

static inline anonymous_record_t record_round_trip(anonymous_record_t value) {
    return value;
}

static inline anonymous_enum_t enum_round_trip(anonymous_enum_t value) {
    return value;
}

static inline named_record pointer_alias_round_trip(named_record value) {
    return value;
}

static inline int (*array_pointer_round_trip(int (*value)[4]))[4] {
    return value;
}

static inline int read_array_factory(int (*(*factory)(void))[4]) {
    return (*factory())[0];
}

static inline int call_vector(
    int (__attribute__((vectorcall)) *callback)(int), int value
) {
    return callback(value);
}

static inline int call_preserve_most(
    int (__attribute__((preserve_most)) *callback)(int), int value
) {
    return callback(value);
}

inline int external_inline_c(int value) {
    return value;
}

static inline _Float16 unsupported_half(_Float16 value) {
    return value;
}

_Float16 unsupported_external_half(_Float16 value);

static inline complex_record_t unsupported_complex_record(complex_record_t value) {
    return value;
}

complex_record_t unsupported_external_complex_record(complex_record_t value);

double_union_t unsupported_external_union(double_union_t value);
bitfield_record_t unsupported_external_bitfield(bitfield_record_t value);

static inline half_record_t unsupported_half_record(half_record_t value) {
    return value;
}

static inline nested_half_record_t unsupported_nested_half_record(nested_half_record_t value) {
    return value;
}

static inline complex_record_t *supported_complex_record_pointer(complex_record_t *value) {
    return value;
}

static inline _Float16 *supported_half_pointer(_Float16 *value) {
    return value;
}

static int unsupported_variadic(const char *format, ...) {
    return format != 0;
}
""".toArray())

            let base = directory.join("bridge.generated")
            let binding = generate(staticWrapperOptions(header.toString(), base.toString()))
            let source = directory.join("bridge.c")
            let sourceCode = String.fromUtf8(File.readFrom(source))

            @Expect(binding.contains("foreign func apply__extern"), true)
            @Expect(binding.contains("public unsafe func apply"), true)
            @Expect(binding.contains("foreign func invoke_old_style__extern"), true)
            @Expect(binding.contains("foreign func reset__extern"), true)
            @Expect(binding.contains("unsupported_variadic"), false)
            @Expect(sourceCode.contains("int apply__extern(callback_t callback"), true)
            @Expect(sourceCode.contains("int invoke_old_style__extern(old_style_callback_t callback)"), true)
            @Expect(sourceCode.contains("void reset__extern(int *value)"), true)
            @Expect(sourceCode.contains("anonymous_record_t record_round_trip__extern(anonymous_record_t value)"), true)
            @Expect(sourceCode.contains("anonymous_enum_t enum_round_trip__extern(anonymous_enum_t value)"), true)
            @Expect(sourceCode.contains("named_record pointer_alias_round_trip__extern(named_record value)"), true)
            @Expect(sourceCode.contains("int (*array_pointer_round_trip__extern(int (*value)[4]))[4]"), true)
            @Expect(sourceCode.contains("int (*(*factory) (void))[4]"), true)
            @Expect(sourceCode.contains("__attribute__((vectorcall)) *callback"), true)
            @Expect(binding.contains("foreign func call_vector__extern"), true)
            @Expect(binding.contains("call_preserve_most"), false)
            @Expect(binding.contains("external_inline_c"), false)
            @Expect(sourceCode.contains("call_preserve_most"), false)
            @Expect(sourceCode.contains("external_inline_c"), false)
            @Expect(binding.contains("unsupported_half"), false)
            @Expect(binding.contains("unsupported_external_half"), false)
            @Expect(binding.contains("unsupported_complex_record"), false)
            @Expect(binding.contains("unsupported_external_complex_record"), false)
            @Expect(binding.contains("unsupported_external_union"), false)
            @Expect(binding.contains("unsupported_external_bitfield"), false)
            @Expect(binding.contains("unsupported_half_constant"), false)
            @Expect(binding.contains("unsupported_half_record"), false)
            @Expect(binding.contains("unsupported_nested_half_record"), false)
            @Expect(binding.contains("foreign func supported_complex_record_pointer__extern"), true)
            @Expect(sourceCode.contains("complex_record_t *supported_complex_record_pointer__extern"), true)
            @Expect(binding.contains("foreign func supported_half_pointer__extern"), true)
            @Expect(sourceCode.contains("_Float16 *supported_half_pointer__extern"), true)
            @Expect(sourceCode.contains("unsupported_variadic"), false)

            let (exitCode, _, _) = executeWithOutput(
                "clang",
                ["-std=c11", "-fsyntax-only", source.toString()]
            )
            @Expect(exitCode, 0)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func emitsNamespacedCxxBridgeAndSkipsExternalInline(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("static_functions.hpp")
            File.writeTo(header, """
namespace math {
struct Point { int value; };
typedef int (*ellipsis_callback_t)(...);

static int operator+(const Point &left, const Point &right) {
    return left.value + right.value;
}

static inline Point *identity(Point *point) {
    return point;
}

static inline int invoke_ellipsis(ellipsis_callback_t callback) {
    return callback(17);
}

static int unsupported_ellipsis_only(...) {
    return 0;
}

int external_ellipsis_only(...);

inline int external_inline(int value) {
    return value;
}
}

namespace {
struct Hidden {
    int member() { return 1; }
    static int staticMember() { return 2; }
};

static int anonymousFreeFunction() {
    return 3;
}
}
""".toArray())

            let base = directory.join("bridge.c")
            let options = staticWrapperOptions(header.toString(), base.toString())
            options.wrapStaticFnsSuffix = "__bridge"
            options.representCxxOperators = true
            let binding = generate(options)
            let source = directory.join("bridge.cpp")
            let sourceCode = String.fromUtf8(File.readFrom(source))

            @Expect(binding.contains("foreign func math_identity__bridge"), true)
            @Expect(binding.contains("public unsafe func math_identity"), true)
            @Expect(binding.contains("foreign func math_invoke_ellipsis__bridge"), true)
            @Expect(binding.contains("public unsafe func math_invoke_ellipsis"), true)
            @Expect(binding.contains("foreign func math_operator_add__bridge"), true)
            @Expect(binding.contains("anonymousFreeFunction__bridge"), true)
            @Expect(binding.contains("unsupported_ellipsis_only"), false)
            @Expect(binding.contains("external_ellipsis_only"), false)
            @Expect(binding.contains("external_inline"), false)
            @Expect(sourceCode.contains("namespace math"), true)
            @Expect(sourceCode.contains("extern \"C\""), true)
            @Expect(sourceCode.contains("math::Point"), true)
            @Expect(sourceCode.contains("ellipsis_callback_t callback"), true)
            @Expect(sourceCode.contains("operator+("), true)
            @Expect(sourceCode.contains("operator_add("), false)
            @Expect(sourceCode.contains("anonymousFreeFunction__bridge"), true)
            @Expect(sourceCode.contains("member__bridge"), false)
            @Expect(sourceCode.contains("staticMember__bridge"), false)
            @Expect(sourceCode.contains("unsupported_ellipsis_only__bridge"), false)
            @Expect(sourceCode.contains("external_ellipsis_only__bridge"), false)
            @Expect(sourceCode.contains("external_inline"), false)

            let (exitCode, _, _) = executeWithOutput(
                "clang++",
                ["-std=c++14", "-fsyntax-only", source.toString()]
            )
            @Expect(exitCode, 0)
        } finally {
            remove(directory, recursive: true)
        }
    }

    @TestCase
    func preservesCxxTemplateArgumentsInBridgeSource(): Unit {
        let directory = Directory.createTemp(getTempDirectory())
        try {
            let header = directory.join("static_template_functions.hpp")
            File.writeTo(header, """
namespace templates {
template <int N, typename T, signed char Marker, unsigned long long Mask>
struct Tagged {
    T value;
};

enum class Color : unsigned short { Red = 7 };
enum Plain : signed char { Negative = -1 };

template <Color C, bool Enabled, Plain P>
struct EnumTagged {
    int value;
};

template <auto V>
struct AutoTagged {
    int value;
};

static inline Tagged<-3, unsigned long, '\\n', 18446744073709551615ULL> *round_trip(
    Tagged<-3, unsigned long, '\\n', 18446744073709551615ULL> *value
) {
    return value;
}

static inline EnumTagged<Color::Red, true, Negative> *enum_round_trip(
    EnumTagged<Color::Red, true, Negative> *enabled,
    EnumTagged<Color::Red, false, Negative> *disabled
) {
    (void)disabled;
    return enabled;
}

static inline AutoTagged<1> *unsupported_auto_round_trip(AutoTagged<1> *value) {
    return value;
}
}
""".toArray())

            let base = directory.join("template_bridge.cpp")
            let options = staticWrapperOptions(header.toString(), base.toString())
            options.clangArgs.add("-std=c++17")
            let binding = generate(options)
            let source = directory.join("template_bridge.cpp")
            let sourceCode = String.fromUtf8(File.readFrom(source))
            let originalType = "templates::Tagged<-3LL, unsigned long, 10LL, 18446744073709551615ULL>"
            let enumTrueType = "templates::EnumTagged<static_cast<::templates::Color>(7ULL), true, static_cast<::templates::Plain>(-1LL)>"
            let enumFalseType = "templates::EnumTagged<static_cast<::templates::Color>(7ULL), false, static_cast<::templates::Plain>(-1LL)>"

            @Expect(binding.contains("foreign func templates_round_trip__extern"), true)
            @Expect(binding.contains("foreign func templates_enum_round_trip__extern"), true)
            @Expect(binding.contains("unsupported_auto_round_trip"), false)
            @Expect(sourceCode.contains(originalType), true)
            @Expect(sourceCode.contains(enumTrueType), true)
            @Expect(sourceCode.contains(enumFalseType), true)
            @Expect(sourceCode.contains("minus_3"), false)
            @Expect(sourceCode.contains("unsupported_auto_round_trip"), false)

            let (exitCode, _, _) = executeWithOutput(
                "clang++",
                ["-std=c++17", "-fsyntax-only", source.toString()]
            )
            @Expect(exitCode, 0)
        } finally {
            remove(directory, recursive: true)
        }
    }
}
