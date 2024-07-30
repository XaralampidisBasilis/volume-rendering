#ifndef PARAMETERS_RAY
#define PARAMETERS_RAY

// struct to hold gradient uniforms
struct parameters_intersection 
{
    vec3 position;
    vec3 normal;
    float value;
    float distance;
    float frag_depth;
};

parameters_intersection intersection;

#endif