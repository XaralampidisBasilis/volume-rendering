#ifndef GRADIENT_UNIFORMS
#define GRADIENT_UNIFORMS

uniform lowp int u_gradient_method;
uniform lowp float u_gradient_resolution;

// struct to hold gradient uniforms
struct gradient_uniforms 
{
    lowp int method;
    lowp float resolution;
};

// function to set light uniforms struct
gradient_uniforms set_gradient_uniforms() 
{
    gradient_uniforms u_gradient;

    u_gradient.method = u_gradient_method;
    u_gradient.resolution = u_gradient_resolution;

    return u_gradient;
}

#endif