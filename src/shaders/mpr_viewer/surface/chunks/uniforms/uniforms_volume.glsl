#ifndef UNIFORMS_VOLUME
#define UNIFORMS_VOLUME

struct Volume 
{
    vec3  dimensions;    
    vec3  spacing;           
    vec3  size;         
    vec3  inv_dimensions;      
    vec3  inv_spacing;   
    vec3  inv_size;            
    float spacing_length;                
    float size_length;  
};

uniform Volume u_volume;

#endif
