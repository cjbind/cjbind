// cjbind-options: --allowlist-function ^selected_api$ -- -x c++ -std=c++14

struct SelectedDependency {
    int value;
};

struct HiddenDependency {
    int value;
};

SelectedDependency selected_api(SelectedDependency value);
HiddenDependency hidden_api(HiddenDependency value);
