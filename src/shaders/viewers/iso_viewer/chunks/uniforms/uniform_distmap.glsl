#ifndef UNIFORM_DISTMAP
#define UNIFORM_DISTMAP

// struct to hold occupancy uniforms
struct Distmap
{
    int   division;
    ivec3 dimensions;            
    vec3  size;                  
    vec3  spacing;          
    vec3  inv_dimensions;        
    vec3  inv_size;              
    vec3  inv_spacing;     
};

uniform Distmap u_distmap;

#endif // UNIFORM_DISTMAP