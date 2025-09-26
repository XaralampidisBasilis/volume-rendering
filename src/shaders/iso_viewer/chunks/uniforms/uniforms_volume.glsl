#ifndef UNIFORMS_VOLUME
#define UNIFORMS_VOLUME

struct UniformsVolume 
{
    ivec3 dimensions;    
    vec3  inv_dimensions;   
    vec3  anisotropy;           
    int   stride;
    ivec3 blocks;        
    mat4  grid_matrix;                 
};

uniform UniformsVolume u_volume;

#endif
