#ifndef UNIFORMS_MINIMA_DISTANCE_MAP
#define UNIFORMS_MINIMA_DISTANCE_MAP

struct MinimaDistanceMap
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

uniform MinimaDistanceMap u_minima_distance_map;

#endif 