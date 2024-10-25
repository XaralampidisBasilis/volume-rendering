#ifndef UNIFORM_GRADIENT
#define UNIFORM_GRADIENT

// struct to hold gradient uniforms
struct Gradient 
{
    vec3 min;
    vec3 max;
    float max_norm;
    float threshold;
};

#endif