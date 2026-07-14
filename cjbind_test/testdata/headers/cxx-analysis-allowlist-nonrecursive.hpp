// cjbind-options: --allowlist-type ^SelectedOuter$ --no-recursive-allowlist -- -x c++ -std=c++14

struct SelectedInner {
    int value;
};

struct SelectedOuter {
    SelectedInner inner;
};

struct HiddenOuter {
    int value;
};
