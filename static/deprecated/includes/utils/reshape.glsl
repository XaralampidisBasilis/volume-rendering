#ifndef UTILS_RESHAPE
#define UTILS_RESHAPE

// pos in [0, size]
int reshape_2d_to_1d(in ivec2 pos2, in ivec2 size) {
    return pos2.x + pos2.y * size.x;
}

// pos in [0, size]
ivec2 reshape_1d_to_2d(in int pos1, in ivec2 size) {
    ivec2 pos2;
    pos2.y = pos1 / size.x;
    pos2.x = pos1 % size.x;
    return pos2;
}

// pos in 0, ..., size - 1
int reshape_3d_to_1d(in ivec3 pos3, in ivec3 size) {
    return pos3.z * size.x * size.y + pos3.y * size.x + pos3.x;
}

// pos in 0, ..., size - 1
ivec3 reshape_1d_to_3d(in int pos1, in ivec3 size) {
    ivec3 pos3;
    int size_xy = size.x * size.y;

    pos3.z = pos1 / size_xy;
    int pos_xy = pos1 % size_xy;
    pos3.y = pos_xy / size.x;
    pos3.x = pos_xy % size.x;
    return pos3;
}

// pos in 0, ..., size - 1
ivec2 reshape_3d_to_2d(in ivec3 pos3, in ivec3 size) {
    ivec2 pos2;
    pos2.x = pos3.x;
    pos2.y = pos3.z * size.y + pos3.y;
    return pos2;
}

// pos in 0, ..., size - 1
ivec3 reshape_2d_to_3d(in ivec2 pos2, in ivec3 size) {
    ivec3 pos3;
    pos3.x = pos2.x;
    pos3.y = pos2.y % size.y;
    pos3.z = pos2.y / size.y;
    return pos3;
}

#endif // UTILS_RESHAPE