#ifndef UNIFORMS_MAXIMA_DISTANCE_MAP
#define UNIFORMS_MAXIMA_DISTANCE_MAP

struct MaximaDistanceMap
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

uniform MaximaDistanceMap u_maxima_distance_map;

#endif 