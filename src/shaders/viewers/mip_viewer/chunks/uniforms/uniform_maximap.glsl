#ifndef UNIFORM_MAXIMAP
#define UNIFORM_MAXIMAP

// struct to hold volume uniforms
struct Maximap 
{
    int   division;
    ivec3 dimensions;            
    vec3  size;                  
    vec3  spacing;          
    vec3  inv_dimensions;        
};

#endif
