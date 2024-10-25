#ifndef UNIFORM_OCCUMAPS
#define UNIFORM_OCCUMAPS

// struct to hold occupancy uniforms
struct Occumaps
{
    int max_skips;
    int min_lod;
    int lods;          
    ivec3 dimensions;    
    ivec3 base_dimensions;
    vec3 base_spacing;  
    vec3 base_size;     
    vec3 min_coords;      
    vec3 max_coords;      
    vec3 min_position;    
    vec3 max_position;    
};

#endif // UNIFORM_OCCUMAPS