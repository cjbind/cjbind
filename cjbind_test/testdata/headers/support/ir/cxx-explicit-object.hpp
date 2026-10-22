struct ExplicitObject {
    int field;
    int value(this ExplicitObject self, int y);
    int reference([[maybe_unused]] this ExplicitObject& self, int y);
    int regular(int y);
    static int static_method(int y);
    int overloaded(this ExplicitObject self, int y);
    int overloaded(this ExplicitObject self, double y);
};

struct ImplicitObject {
    ImplicitObject();
    ~ImplicitObject();
};
