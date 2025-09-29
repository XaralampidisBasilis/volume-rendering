#ifndef UNIFORMS_VOLUME
#define UNIFORMS_VOLUME

struct UniformsVolume 
{
    float isovalue;
    ivec3 dimensions;    
    vec3  inv_dimensions;   
    vec3  spacing;           
    int   block_size;
};

uniform UniformsVolume u_volume;

#endif
