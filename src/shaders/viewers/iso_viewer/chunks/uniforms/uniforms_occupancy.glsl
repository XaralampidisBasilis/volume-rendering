#ifndef OCCUPANCY_UNIFORMS
#define OCCUPANCY_UNIFORMS

// struct to hold occupancy uniforms
struct uniforms_occupancy 
{
    vec3 occumap_dimensions; 
    vec3 block_dimensions;  
    vec3 box_min;
    vec3 box_max;
    int divisions;
    int method;
};

uniform uniforms_occupancy u_occupancy;

#endif