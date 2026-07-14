// cjbind-options: -- -x c++ -std=c++20

struct alignas(16) Wide {
    long long values[2];
};

Wide echoWide(Wide value);
Wide* passthroughWide(Wide* value);
long double echoLongDouble(long double value);
__int128 echoInt128(__int128 value);

struct Empty {};

struct NoUniqueAddress {
    [[no_unique_address]] Empty empty;
    double value;
};

NoUniqueAddress echoNoUniqueAddress(NoUniqueAddress value);
NoUniqueAddress* passthroughNoUniqueAddress(NoUniqueAddress* value);
using NoUniqueAddressCallback = NoUniqueAddress (*)(NoUniqueAddress);
void installNoUniqueAddressCallback(NoUniqueAddressCallback callback);

struct __attribute__((packed)) PackedValue {
    char first;
    int second;
};

PackedValue echoPackedValue(PackedValue value);
PackedValue* passthroughPackedValue(PackedValue* value);

struct PackedContainer {
    PackedValue packed;
};

PackedContainer echoPackedContainer(PackedContainer value);
PackedContainer* passthroughPackedContainer(PackedContainer* value);

struct DeletedMoves {
    DeletedMoves() = default;
    DeletedMoves(const DeletedMoves&) = delete;
    DeletedMoves(DeletedMoves&&) = delete;
    int value;
};

DeletedMoves echoDeletedMoves(DeletedMoves value);
DeletedMoves* passthroughDeletedMoves(DeletedMoves* value);

struct DeletedMoveContainer {
    DeletedMoves value;
};

DeletedMoveContainer echoDeletedMoveContainer(DeletedMoveContainer value);
DeletedMoveContainer* passthroughDeletedMoveContainer(DeletedMoveContainer* value);

struct PrivateCopy {
    PrivateCopy() = default;
    int value;
private:
    PrivateCopy(const PrivateCopy&) = default;
};

struct PrivateCopyContainer {
    PrivateCopy value;
};

PrivateCopyContainer echoPrivateCopyContainer(PrivateCopyContainer value);
PrivateCopyContainer* passthroughPrivateCopyContainer(PrivateCopyContainer* value);
