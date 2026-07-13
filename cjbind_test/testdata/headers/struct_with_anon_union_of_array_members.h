struct bpf_array {
    union {
        struct {
            struct {} __empty_value1;
            char value1[];
        };
        struct {
            struct {} __empty_value2;
            char value2[];
        };
    };
};
