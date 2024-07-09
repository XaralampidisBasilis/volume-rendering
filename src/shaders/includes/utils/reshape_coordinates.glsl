#ifndef UTILS_RESHAPE_COORDINATES
#define UTILS_RESHAPE_COORDINATES

float reshape_3d_to_1d(in vec3 pos3, in vec3 size)
{
    // pos in [0, size]
    return pos3.z * size.x * size.y + pos3.y * size.x + pos3.x;
}

vec3 reshape_1d_to_3d(in float pos1, in vec3 size)
{
    // pos in [0, size]
    vec3 pos3;

    float size_xy = size.x * size.y;
    pos3.z = floor(pos1 / size_xy);

    float pos_xy = mod(pos1, size_xy);
    pos3.y = floor(pos_xy / size.x);
    pos3.x = mod(pos_xy, size.x);

    return pos3;
}

vec2 reshape_3d_to_2d(in vec3 pos3, in vec3 size)
{
    // pos in [0, size]
    vec2 pos2;
    pos2.x = pos3.x;
    pos2.y = floor(pos3.z) * size.y + pos3.y;

    return floor(pos2);
}

vec3 reshape_2d_to_3d(in vec2 pos2, in vec3 size)
{
    // pos in [0, size]
    vec3 pos3;
    pos3.x = pos2.x;
    pos3.y = mod(pos2.y, size.y);
    pos3.z = floor(pos2.y / size.y);

    return floor(pos3);
}

// In normalized texel coordinates

float reshape_3d_to_1d_texel(in vec3 pos3, in vec3 size)
{
    // pos3 in [0, 1]
    float size_xyz = size.x * size.y * size.z;
    return reshape_3d_to_1d(pos3 * size, size) / size_xyz;
}

vec3 reshape_1d_to_3d_texel(in float pos1, in vec3 size)
{
    // pos1 in [0, 1]
    float size_xyz = size.x * size.y * size.z;
    return reshape_1d_to_3d(pos1 * size_xyz, size) / size;
}

vec2 reshape_3d_to_2d_texel(in vec3 pos3, in vec3 size)
{
    // pos in [0, 1]
    vec2 size2 = vec2(size.x, size.y * size.z);
    return reshape_3d_to_2d(pos3 * size, size) / size2;
}

vec3 reshape_2d_to_3d_texel(in vec2 pos2, in vec3 size)
{
    // pos in [0, 1]
    vec2 size2 = vec2(size.x, size.y * size.z); 
    return reshape_2d_to_3d(pos2 * size2, size) / size;
}



// Overload functions

// INT

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

// UINT


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

#endif // UTILS_RESHAPE_COORDINATES