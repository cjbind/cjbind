// cjbind-options: -- -x c++ -std=c++14

template<typename T>
struct Box {
    T value;
    T* pointer;
};

template<>
struct Box<char> {
    double specialized;
};

template<typename T>
struct Wrap {
    Box<T> nested;
};

template<typename T>
using BoxPtr = Box<T>*;

template<typename T>
using Ptr = T*;

template<int N>
struct Fixed {
    char values[N];
};

template<int N>
struct Tag {
    int value;
};

template<char C>
struct CharTag {
    char value;
};

template<typename T = int>
struct DefaultBox {
    T value;
};

template<typename T>
struct CallbackWrap {
    Box<T>* nested;
    T (*callback)(T);
};

struct Holder {
    Box<int> integers;
    Box<double> doubles;
    Box<char> specialized;
    Wrap<int> nested;
    Fixed<4> fixed;
    Fixed<8> largerFixed;
    Tag<-1> negative;
    CharTag<'\n'> escaped;
    DefaultBox<> defaulted;
    DefaultBox<int> explicitDefault;
    CallbackWrap<int> callbackWrap;
};

struct AliasHolder {
    BoxPtr<int> value;
    Ptr<int> integer;
    Ptr<double> floating;
};

void consume(Box<int> value);
