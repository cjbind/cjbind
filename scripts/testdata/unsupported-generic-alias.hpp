template <typename T>
using FastCallback = T (_fastcall *)(T);

FastCallback<int> make_fast_callback();
