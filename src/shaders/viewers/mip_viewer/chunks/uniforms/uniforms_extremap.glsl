#ifndef UNIFORMS_EXTREMAP
#define UNIFORMS_EXTREMAP

// struct to hold occupancy uniforms
struct Extremap
{
    int   sub_division;
    ivec3 dimensions;    
    vec3  spacing;                  
    vec3  size;                  
    vec3  inv_dimensions;   
    vec3  inv_spacing;          
    vec3  inv_size;              
};

uniform Extremap u_extremap;

#endif // UNIFORMS_EXTREMAP