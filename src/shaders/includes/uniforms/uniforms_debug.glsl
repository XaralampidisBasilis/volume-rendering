#ifndef UNIFORMS_DEBUG
#define UNIFORMS_DEBUG

// struct to hold colormap uniforms
struct uniforms_debug 
{
    int option;
    float scale;
    float probability;
    float constant;
};

uniform uniforms_debug u_debug;

#endif