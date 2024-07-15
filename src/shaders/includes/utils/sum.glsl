#ifndef UTILS_SUM
#define UTILS_SUM

// vec

float sum(in vec2 vector)
{
    return vector.x + vector.y;
}

float sum(in vec3 vector)
{
    return vector.x + vector.y + vector.z;
}

float sum(in vec4 vector)
{
    return vector.x + vector.y + vector.z + vector.w;
}

// ivec

int sum(in ivec2 vector)
{
    return int(sum(vec2(vector)));
}

int sum(in ivec3 vector)
{
    return int(sum(vec3(vector)));
}

int sum(in ivec4 vector)
{
    return int(sum(vec4(vector)));
}

// bvec

#endif // UTILS_SUM