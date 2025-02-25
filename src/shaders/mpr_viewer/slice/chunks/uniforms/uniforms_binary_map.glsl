#ifndef UNIFORMS_BINARY_MAP
#define UNIFORMS_BINARY_MAP

struct BinaryMap 
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

uniform BinaryMap u_binary_map;

#endif
