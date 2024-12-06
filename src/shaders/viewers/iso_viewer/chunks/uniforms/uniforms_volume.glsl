#ifndef UNIFORMS_VOLUME
#define UNIFORMS_VOLUME

// struct to hold volume uniforms
struct Volume 
{
    ivec3 dimensions;    
    vec3  spacing;           
    float spacing_length;                
    vec3  size;         
    float size_length;  
    vec3  inv_dimensions;      
    vec3  inv_spacing;   
    vec3  inv_size;            
    float inv_spacing_length;                  
    float inv_size_length;         
    vec3  min_position;          
    vec3  max_position;          
    vec3  min_gradient;          
    vec3  max_gradient;          
    float max_gradient_length;
};

uniform Volume u_volume;

#endif
