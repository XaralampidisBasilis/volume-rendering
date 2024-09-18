#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

// struct to hold gradient uniforms
struct uniforms_gradient 
{
    float threshold;
    float max_norm;
    int method;
};

uniform uniforms_gradient u_gradient;

#endif