#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

// struct to hold gradient uniforms
struct uniforms_gradient 
{
    float resolution;
    int method;
    float neighbor;
};

uniform uniforms_gradient u_gradient;

#endif