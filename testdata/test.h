struct Structure {
    int foo;
    float bar;
};

typedef void (*OperationCallback)(int);

void register_callback(void (*callback)(int));

void perform_operation(int value, OperationCallback callback);