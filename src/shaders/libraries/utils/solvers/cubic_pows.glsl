#ifndef CUBIC_POWS
#define CUBIC_POWS

vec4 cubic_pows(in float t)
{
    float t2 = t * t;
    return vec4(1.0, t, t2, t * t2);
}

#endif