#ifndef OCCUMAPS_UNIFORMS
#define OCCUMAPS_UNIFORMS

// struct to hold occumaps uniforms
struct uniforms_occumaps 
{
    int lods;          
    ivec3 dimensions;    
    ivec3 base_dimensions;
    vec3 base_spacing;  
    vec3 base_size;     
};

uniform uniforms_occumaps u_occumaps;

#endif