#ifndef OCCUPANCY_UNIFORMS
#define OCCUPANCY_UNIFORMS

// struct to hold occupancy uniforms
struct uniforms_occupancy 
{
    float threshold;       
    vec3 occumap_max_dims;
    int occumap_num_lod;
    vec3 occumap_size;
    vec3 block_min_dims;  
    vec3 block_min_size;
    vec3 min_coords;      
    vec3 max_coords;      
    vec3 min_position;    
    vec3 max_position;    
};

uniform uniforms_occupancy u_occupancy;

#endif