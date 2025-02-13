#ifndef UNIFORMS_DISTANCE_MAP
#define UNIFORMS_DISTANCE_MAP

struct DistanceMap
{
    int   max_distance;
    ivec3 dimensions;    
    vec3  spacing;                  
    vec3  size;            
    float inv_sub_division;      
    vec3  inv_dimensions;   
    vec3  inv_spacing;          
    vec3  inv_size;              
};

uniform DistanceMap u_distance_map;

#endif 