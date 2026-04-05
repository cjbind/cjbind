// cjbind-options: --clang-arg --target=i686-pc-win32


typedef void (__stdcall *void_fn)();
typedef void_fn (__stdcall *fn)(int id);
