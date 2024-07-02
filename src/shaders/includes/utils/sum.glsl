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
    return vector.x + vector.y;
}

int sum(in ivec3 vector)
{
    return vector.x + vector.y + vector.z;
}

int sum(in ivec4 vector)
{
    return vector.x + vector.y + vector.z + vector.w;
}

#endif // UTILS_SUM