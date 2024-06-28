#ifndef VOLUME_UNIFORMS
#define VOLUME_UNIFORMS

uniform vec3 u_volume_size;
uniform vec3 u_volume_dimensions;
uniform vec3 u_volume_voxel;

// struct to hold volume uniforms
struct volume_uniforms 
{
    vec3 size;
    vec3 dimensions;
    vec3 voxel;
};

#endif
