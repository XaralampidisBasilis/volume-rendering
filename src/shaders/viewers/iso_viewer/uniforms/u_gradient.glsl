#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

// struct to hold gradient uniforms
struct gradient_uniforms 
{
    float resolution;
    int method;
    float neighbor;
};

uniform gradient_uniforms u_gradient;

#endif