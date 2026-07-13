// cjbind-options: --clang-arg -x --clang-arg c++ --clang-arg -std=c++14 --respect-cxx-access-specs --use-specific-virtual-function-receiver

#ifndef CJBIND_TEST_CXX_RUNTIME_LIFECYCLE_HPP
#define CJBIND_TEST_CXX_RUNTIME_LIFECYCLE_HPP

class LifecycleProbe {
public:
    LifecycleProbe();
    explicit LifecycleProbe(int value);
    ~LifecycleProbe();

    int value() const;
    static int add(int left, int right);

private:
    int stored_;
};

extern "C" int lifecycle_live_count();

class RuntimeLeft {
public:
    RuntimeLeft();
    virtual int left() const;

protected:
    int padding_;
};

class RuntimeRight {
public:
    RuntimeRight();
    virtual int right() const;
};

class MultipleProbe : public RuntimeLeft, public RuntimeRight {
public:
    explicit MultipleProbe(int value);
    ~MultipleProbe();
    int left() const override;
    int right() const override;

private:
    int stored_;
};

#endif
