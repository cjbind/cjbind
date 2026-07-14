template <typename T>
class UsesTemplateParameter {
    T t;

    class AlsoUsesTemplateParameter {
        T also;
    };
};
