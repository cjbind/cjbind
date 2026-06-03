typedef struct toml_datum_t toml_datum_t;

struct toml_datum_t {
  int type;
  union {
    const char *s;
    struct {
      const char *ptr;
      int len;
    } str;
    struct {
      int size;
      toml_datum_t *elem;
    } arr;
    struct {
      int size;
      const char **key;
      int *len;
      toml_datum_t *value;
    } tab;
  } u;
};
