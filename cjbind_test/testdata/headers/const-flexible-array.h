typedef struct ConstPacket {
  int size;
  const unsigned short payload[];
} ConstPacket;

typedef union MultiZero {
  int first[0];
  unsigned short second[0];
  const unsigned char read_only[0];
  int scalar;
} MultiZero;

typedef struct FirstItems {
  int size;
  int items[];
} FirstItems;

typedef struct SecondItems {
  int size;
  int items[];
} SecondItems;
