#ifndef PARAMETERS_RAY
#define PARAMETERS_RAY

// struct to hold gradient uniforms
struct parameters_ray 
{
    vec3 origin;
    vec3 direction;
    vec3 position;
    vec3 normal;
    vec3 step; 
    vec2 bounds;
    float span;
    float dither;
    float value;
    float depth;
    float delta;
    int num_steps;
};

parameters_ray ray;

#endif