#ifndef OCCUPANCY_UNIFORMS
#define OCCUPANCY_UNIFORMS

// struct to hold occupancy uniforms
struct uniforms_occupancy 
{
    float threshold;         
    vec3 min_coords;      
    vec3 max_coords;      
    vec3 min_position;    
    vec3 max_position;    
};

uniform uniforms_occupancy u_occupancy;

#endif