#ifndef OCCUPANCY_UNIFORMS
#define OCCUPANCY_UNIFORMS

// struct to hold occupancy uniforms
struct uniforms_occupancy 
{
    vec3 size; 
    vec3 block;  
    vec3 box_min;
    vec3 box_max;
    int resolution;
    int method;
};

uniform uniforms_occupancy u_occupancy;

#endif