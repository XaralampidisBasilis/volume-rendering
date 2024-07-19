#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

// struct to hold gradient uniforms
struct uniforms_gradient 
{
    float threshold;
    float resolution;
    int method;
    bool max_sampling;
};

uniform uniforms_gradient u_gradient;

#endif