#ifndef OCCUPANCY_UNIFORMS
#define OCCUPANCY_UNIFORMS

// struct to hold occupancy uniforms
struct occupancy_uniforms 
{
    vec3 size; 
    vec3 block;  
    vec3 box_min;
    vec3 box_max;
    int resolution;
    int method;
};

uniform occupancy_uniforms u_occupancy;

#endif