#ifndef UNIFORM_DISTMAP
#define UNIFORM_DISTMAP

// struct to hold occupancy uniforms
struct Distmap
{
    int   division;
    ivec3 dimensions;            
    vec3  size;                  
    vec3  spacing;          
    float size_length;
    float spacing_length;     
    vec3  inv_dimensions;        
    vec3  inv_size;              
    vec3  inv_spacing;     
    float inv_size_length;
    float inv_spacing_length;      
};

uniform Distmap u_distmap;

#endif // UNIFORM_DISTMAP