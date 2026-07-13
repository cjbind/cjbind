#include "../testdata/headers/cxx-runtime-lifecycle.hpp"

namespace {
int live_count = 0;
}

LifecycleProbe::LifecycleProbe() : stored_(7) {
    ++live_count;
}

LifecycleProbe::LifecycleProbe(int value) : stored_(value) {
    ++live_count;
}

LifecycleProbe::~LifecycleProbe() {
    --live_count;
}

int LifecycleProbe::value() const {
    return stored_;
}

int LifecycleProbe::add(int left, int right) {
    return left + right;
}

extern "C" int lifecycle_live_count() {
    return live_count;
}

RuntimeLeft::RuntimeLeft() : padding_(0) {}

int RuntimeLeft::left() const {
    return padding_;
}

RuntimeRight::RuntimeRight() {}

int RuntimeRight::right() const {
    return -1;
}

MultipleProbe::MultipleProbe(int value) : stored_(value) {}

MultipleProbe::~MultipleProbe() {}

int MultipleProbe::left() const {
    return stored_ + 1;
}

int MultipleProbe::right() const {
    return stored_ + 2;
}
