#ifndef UNIFORMS_DISTMAP
#define UNIFORMS_DISTMAP

// struct to hold occupancy uniforms
struct Distmap
{
    int   max_distance;
    int   sub_division;
    ivec3 dimensions;    
    vec3  spacing;                  
    vec3  size;                  
    vec3  inv_dimensions;   
    vec3  inv_spacing;          
    vec3  inv_size;              
};

uniform Distmap u_distmap;

#endif // UNIFORMS_DISTMAP