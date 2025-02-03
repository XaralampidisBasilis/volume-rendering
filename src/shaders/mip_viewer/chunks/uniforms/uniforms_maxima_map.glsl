#ifndef UNIFORMS_MAXIMA_MAP
#define UNIFORMS_MAXIMA_MAP

struct MaximaMap
{
    int   sub_division;
    ivec3 dimensions;    
    vec3  spacing;                  
    vec3  size;            
    float inv_sub_division;      
    vec3  inv_dimensions;   
    vec3  inv_spacing;          
    vec3  inv_size;              
};

uniform MaximaMap u_maxima_map;

#endif 