struct FullWordWidth {
    unsigned long long full : 64;
};

struct ShiftedWordWidth {
    unsigned long long first : 1;
    unsigned long long rest : 63;
};
