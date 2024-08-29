#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

// struct to hold gradient uniforms
struct uniforms_gradient 
{
    float threshold;
    float resolution;
    float min_length;
    float max_length;
    float length_range;
    int method;
    bool max_sampling;
};

uniform uniforms_gradient u_gradient;

#endif