// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --allowlist-type ^SelectedOuter$ --no-recursive-allowlist

struct SelectedInner {
    int value;
};

struct SelectedOuter {
    SelectedInner inner;
};

struct HiddenOuter {
    int value;
};
