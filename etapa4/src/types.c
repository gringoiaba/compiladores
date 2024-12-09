#include "types.h"

Type typeInfer(Type type1, Type type2) {
    if (type1 >= type2) return type1;
    return type2;
}