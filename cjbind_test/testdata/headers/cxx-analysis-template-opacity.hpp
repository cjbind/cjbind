// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --opaque-type ^SelectiveOpaque<int>$

template <typename T>
struct __attribute__((packed)) PackedTemplate {
    char tag;
    T value;
};

template <typename T, unsigned Width>
struct DependentBitfield {
    T value : Width;
};

template <typename T, int Count>
struct NonTypeTemplate {
    T values[Count];
};

template <typename T>
struct SelectiveOpaque {
    T value;
};

struct TemplateOpacityHolder {
    PackedTemplate<int> packed;
    DependentBitfield<unsigned, 7> dependentBitfield;
    NonTypeTemplate<short, 5> nonType;
    SelectiveOpaque<int> selectedOpaque;
    SelectiveOpaque<float> visible;
};
