#ifndef UNIFORM_VOLUME
#define UNIFORM_VOLUME

// struct to hold volume uniforms
struct Volume 
{
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
    vec3  min_gradient;          
    vec3  max_gradient;          
    float max_gradient_length;
};

#endif
