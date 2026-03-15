// cjbind-options: --default-enum-style newtype
// Test simple enum for NewType generation
enum Color {
    RED = 0,
    GREEN = 1,
    BLUE = 2
};

// Test enum with explicit unsigned values
enum Status {
    OK = 0,
    ERROR = 1,
    PENDING = 2,
    TIMEOUT = 255
};
