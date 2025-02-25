#ifndef UNIFORMS_INTENSITY_MAP
#define UNIFORMS_INTENSITY_MAP

struct IntensityMap 
{
    ivec3 dimensions;    
    vec3  spacing;           
    vec3  size;         
    vec3  inv_dimensions;      
    vec3  inv_spacing;   
    vec3  inv_size;            
    float spacing_length;                
    float size_length;  
};

uniform IntensityMap u_intensity_map;

#endif
