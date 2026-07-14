#pragma once

template <typename T, typename Unused>
struct AnalysisTemplateInput {
    T value;
};

struct AnalysisVirtualBaseInput {
    virtual ~AnalysisVirtualBaseInput() = default;
};

struct AnalysisConcreteInput : AnalysisVirtualBaseInput {
    AnalysisTemplateInput<float, int> payload;
};
