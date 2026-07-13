#pragma clang system_header

typedef struct objc_object {
    void *isa;
} *id;

typedef struct objc_class *Class;
typedef struct objc_selector *SEL;
