struct Structure {
    int foo;
    float bar;
};

typedef void (*OperationCallback)(int);

void register_callback(void (*callback)(int));

void perform_operation(int value, OperationCallback callback);

static const char* GREETING = "Hello";  // 只读字符串
static char message[] = "Initial中文字符";      // 可修改字符数组（但每个副本独立）