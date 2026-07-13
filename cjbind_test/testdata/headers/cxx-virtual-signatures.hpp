// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --vtable-generation --generate-pure-virtual-functions --use-specific-virtual-function-receiver

class RecursiveDerived;

class RecursiveBase {
public:
    virtual RecursiveDerived* asDerived();
    virtual void update(char value) = 0;
    virtual void update(int value) = 0;
    virtual ~RecursiveBase();
};

class RecursiveDerived : public RecursiveBase {
public:
    RecursiveDerived* asDerived() override;
    void update(char value) override;
    void update(int value) override;
};

class Secondary {
public:
    virtual int secondary() = 0;
};

class MultipleInterface final : public RecursiveDerived, public Secondary {
public:
    int secondary() override;
};
