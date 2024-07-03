#ifndef OCCUPANCY_UNIFORMS
#define OCCUPANCY_UNIFORMS

uniform vec3 u_occupancy_size;
uniform vec3 u_occupancy_block;
uniform vec3 u_occupancy_box_min;
uniform vec3 u_occupancy_box_max;
uniform int u_occupancy_method;

// struct to hold occupancy uniforms
struct occupancy_uniforms 
{
    vec3 size; 
    vec3 block;  
    vec3 box_min;
    vec3 box_max;
    int method;
};

#endif