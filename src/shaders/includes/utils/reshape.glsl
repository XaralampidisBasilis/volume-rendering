#ifndef UTILS_RESHAPE
#define UTILS_RESHAPE

int reshape_2d_to_1d(in ivec2 pos2, in ivec2 size)
{
    // pos in [0, size]
    return pos2.x + pos2.y * size.x;
}

ivec2 reshape_1d_to_2d(in int pos1, in ivec2 size)
{
    // pos in [0, size]
    ivec2 pos2;

    pos2.y = pos1 / size.x;
    pos2.x = pos1 % size.x;

    return pos2;
}

int reshape_3d_to_1d(in ivec3 pos3, in ivec3 size)
{
    // pos in 0, ..., size - 1
    return pos3.z * size.x * size.y + pos3.y * size.x + pos3.x;
}

ivec3 reshape_1d_to_3d(in int pos1, in ivec3 size)
{
    // pos in 0, ..., size - 1
    ivec3 pos3;

    int size_xy = size.x * size.y;
    pos3.z = pos1 / size_xy;

    int pos_xy = pos1 % size_xy;
    pos3.y = pos_xy / size.x;
    pos3.x = pos_xy % size.x;

    return pos3;
}

ivec2 reshape_3d_to_2d(in ivec3 pos3, in ivec3 size)
{
    // pos in 0, ..., size - 1
    ivec2 pos2;
    pos2.x = pos3.x;
    pos2.y = pos3.z * size.y + pos3.y;

    return pos2;
}

ivec3 reshape_2d_to_3d(in ivec2 pos2, in ivec3 size)
{
    // pos in 0, ..., size - 1
    ivec3 pos3;
    pos3.x = pos2.x;
    pos3.y = pos2.y % size.y;
    pos3.z = pos2.y / size.y;

    return pos3;
}

// Overload

uint reshape_2d_to_1d(in uvec2 pos2, in uvec2 size)
{
    // pos in [0, size]
    return pos2.x + pos2.y * size.x;
}

uvec2 reshape_1d_to_2d(in uint pos1, in uvec2 size)
{
    // pos in [0, size]
    uvec2 pos2;

    pos2.y = pos1 / size.x;
    pos2.x = pos1 % size.x;

    return pos2;
}

uint reshape_3d_to_1d(in uvec3 pos3, in uvec3 size)
{
    // pos in 0, ..., size - 1
    return pos3.z * size.x * size.y + pos3.y * size.x + pos3.x;
}

uvec3 reshape_1d_to_3d(in uint pos1, in uvec3 size)
{
    // pos in 0, ..., size - 1
    uvec3 pos3;

    uint size_xy = size.x * size.y;
    pos3.z = pos1 / size_xy;

    uint pos_xy = pos1 % size_xy;
    pos3.y = pos_xy / size.x;
    pos3.x = pos_xy % size.x;

    return pos3;
}

uvec2 reshape_3d_to_2d(in uvec3 pos3, in uvec3 size)
{
    // pos in 0, ..., size - 1
    uvec2 pos2;
    pos2.x = pos3.x;
    pos2.y = pos3.z * size.y + pos3.y;

    return pos2;
}

uvec3 reshape_2d_to_3d(in uvec2 pos2, in uvec3 size)
{
    // pos in 0, ..., size - 1
    uvec3 pos3;
    pos3.x = pos2.x;
    pos3.y = pos2.y % size.y;
    pos3.z = pos2.y / size.y;

    return pos3;
}

#endif // UTILS_RESHAPE