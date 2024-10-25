#ifndef UNIFORM_VOLUME
#define UNIFORM_VOLUME

// struct to hold volume uniforms
struct Volume 
{
    ivec3 dimensions;            
    vec3  size;                  
    vec3  spacing;               
    vec3  inv_dimensions;        
    vec3  inv_size;              
    vec3  inv_spacing;           
    ivec3 min_coords;            
    ivec3 max_coords;            
    vec3  min_position;          
    vec3  max_position;          
    vec3  min_gradient;          
    vec3  max_gradient;          
    float max_gradient_magnitude;
};

#endif
