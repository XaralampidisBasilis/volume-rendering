#ifndef UNIFORMS_DEBUG
#define UNIFORMS_DEBUG

// struct to hold colormap uniforms
struct Debug 
{
    int option;
    int number;
    float scale;
    float constant;
    float mixing;
    float epsilon;
    float tolerance;
    vec3 texel;
};

#endif