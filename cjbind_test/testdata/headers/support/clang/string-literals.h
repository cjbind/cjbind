#define STRING_BYTES "a\0" "b"
static const char array[] = "a\0b";
static const char padded[20] = "a\0b";
static const char *const pointer = ("a\0b");
static const char macro_expansion[] = STRING_BYTES;
static const char *const offset = "abc" + 1;
static const char *const conditional = 0 ? "wrong" : "right";
