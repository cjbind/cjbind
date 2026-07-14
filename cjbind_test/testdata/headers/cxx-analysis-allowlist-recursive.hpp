// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --allowlist-function ^selected_api$

struct SelectedDependency {
    int value;
};

struct HiddenDependency {
    int value;
};

SelectedDependency selected_api(SelectedDependency value);
HiddenDependency hidden_api(HiddenDependency value);
