#ifndef UTILS_RAND
#define UTILS_RAND

float rand(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898, 78.233)) + 1.0) * 43758.5453);
}

#endif // UTILS_RAND