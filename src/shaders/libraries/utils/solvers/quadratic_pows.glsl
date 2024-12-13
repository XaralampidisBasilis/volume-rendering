#ifndef QUADRATIC_POWS
#define QUADRATIC_POWS

vec3 quadratic_pows(in float t)
{
    return vec3(1.0, t, t * t);
}

#endif