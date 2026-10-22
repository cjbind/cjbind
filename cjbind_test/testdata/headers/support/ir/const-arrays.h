extern const int const_one[2];
extern const int const_two[2][3];
extern const int const_three[2][3][4];
extern const int const_incomplete[][3][4];
extern int mutable_three[2][3][4];
extern const int *mutable_pointers[2][3];
extern int *const const_pointers[2][3];
extern const int (*mutable_pointer_to_array)[2][3];

void takes_const_array(const int values[2][3][4]);
