#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

uniform int u_gradient_method;
uniform float u_gradient_resolution;
uniform float u_gradient_neighbor;

// struct to hold gradient uniforms
struct gradient_uniforms 
{
    int method;
    float resolution;
    float neighbor;
};

#endif