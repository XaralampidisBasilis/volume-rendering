#ifndef UNIFORMS_CONTROLS
#define UNIFORMS_CONTROLS

// struct to hold colormap uniforms
struct Controls 
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