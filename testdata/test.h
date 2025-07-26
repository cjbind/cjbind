#include <stdio.h>

#define INT_MACRO 42
#define FLOAT_MACRO 3.14f
#define STRING_MACRO "Hello, World!"
#define CHAR_MACRO 'A'

enum E1 {
    A,
    B,
    C
};

enum {
    UA,
    UB,
    UC
};

struct Some {
    int a;
    char b;
};

void f(char [233]);

char* ss = "hello";