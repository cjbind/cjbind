// cjbind-options: --clang-arg --target=x86_64-unknown-linux-gnu
#define POINTER_WIDTH (sizeof(void*) * 8)

struct Foo {
  unsigned long m_bitfield: POINTER_WIDTH;
  unsigned long m_bar: POINTER_WIDTH;
  unsigned long foo: 1;
  unsigned long bar: POINTER_WIDTH;
};
