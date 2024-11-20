#ifndef UNIFORM_EXTREMAP
#define UNIFORM_EXTREMAP

// struct to hold volume uniforms
struct Extremap 
{
    int   divisions;
    ivec3 dimensions;            
    vec3  size;                  
    vec3  spacing;          
    vec3  inv_dimensions;        
    vec3  inv_spacing;        
    vec3  inv_size;        
};

#endif
