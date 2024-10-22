#ifndef UNIFORMS_DEBUG
#define UNIFORMS_DEBUG

// struct to hold colormap uniforms
struct uniforms_debug 
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

uniform uniforms_debug u_debug;

#endif