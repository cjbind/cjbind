#include <configured.h>

#if defined(__cplusplus) && __cplusplus < 202002L
#error The fallback parser must retain the requested C++ language standard.
#endif

#define FROM_CONFIG (CJBIND_CONFIG_VALUE + CJBIND_INCLUDED_VALUE + CJBIND_PREFIX_VALUE + 1)
