#ifndef UNIFORM_OCCUMAPS
#define UNIFORM_OCCUMAPS

// struct to hold occupancy uniforms
struct Occumaps
{
    int   atlas_lods;          
    ivec3 atlas_dimensions;    
    ivec3 base_dimensions;
    vec3  base_spacing;
    vec3  base_size;        
};

#endif // UNIFORM_OCCUMAPS