#ifndef UNIFORMS_VOLUME
#define UNIFORMS_VOLUME

struct UniformsVolume 
{
    float isovalue;
    ivec3 dimensions;    
    vec3  spacing;           
    vec3  inv_dimensions;   
    int   block_size;
    ivec3 blocked_dimensions;
};

uniform UniformsVolume u_volume;

#endif
