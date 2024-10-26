#ifndef UNIFORM_OCCUMAPS
#define UNIFORM_OCCUMAPS

// struct to hold occupancy uniforms
struct Occumaps
{
    int   min_lod;          
    int   max_lod;          
    ivec3 dimensions;    
    ivec3 base_dimensions;
    vec3  base_spacing;
    vec3  base_size;        
};

#endif // UNIFORM_OCCUMAPS