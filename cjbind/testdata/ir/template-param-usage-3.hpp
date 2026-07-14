template <typename T>
class UsesTemplateParameter {
    T t;

    template <typename U>
    class AlsoUsesTemplateParameterAndMore {
        T also;
        U more;
    };
};
