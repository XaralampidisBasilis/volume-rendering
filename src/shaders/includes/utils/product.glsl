#ifndef UTILS_PRODUCT
#define UTILS_PRODUCT

// vec

float product(in vec2 vector)
{
    return vector.x * vector.y;
}

float product(in vec3 vector)
{
    return vector.x * vector.y * vector.z;
}

float product(in vec4 vector)
{
    return vector.x * vector.y * vector.z * vector.w;
}

// ivec

int product(in ivec2 vector)
{
    return vector.x * vector.y;
}

int product(in ivec3 vector)
{
    return vector.x * vector.y * vector.z;
}

int product(in ivec4 vector)
{
    return vector.x * vector.y * vector.z * vector.w;
}

#endif // UTILS_PRODUCT