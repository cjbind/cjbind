#ifndef TEST_EXTERN_C_H
#define TEST_EXTERN_C_H

extern "C" {

void simple_function_nocheck();
int calculate_product(int a, int b);
float get_temperature(const char* sensor_id);

#ifdef __cplusplus
void debug_message(const char* msg, int level = 0);
#else
void debug_message(const char* msg, int level);
#endif

struct ConfigWrapper {
    int version;
    void* handle;
};

void config_update(ConfigWrapper& wrapper);

void draw_shape(int sides);

using namespace std;

using ByteBuffer = unsigned char*;

}
#endif
