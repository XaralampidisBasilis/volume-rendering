#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

// struct to hold gradient uniforms
struct uniforms_gradient 
{
    float threshold;
    float min_length;
    float max_length;
    float length_range;
    int method;
};

uniform uniforms_gradient u_gradient;

#endif