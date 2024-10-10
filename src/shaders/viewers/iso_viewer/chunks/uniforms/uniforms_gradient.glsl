#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

// struct to hold gradient uniforms
struct uniforms_gradient 
{
    vec3 min;
    vec3 max;
    float max_norm;
    float threshold;
};

uniform uniforms_gradient u_gradient;

#endif