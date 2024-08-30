#ifndef VOLUME_UNIFORMS
#define VOLUME_UNIFORMS

// uniform vec3 u_volume_size;
// uniform vec3 u_volume_dimensions;
// uniform vec3 u_volume_voxel;

// struct to hold volume uniforms
struct uniforms_volume 
{
    vec3 dimensions;
    vec3 size;
    vec3 spacing;
    vec3 inv_dimensions;
    vec3 inv_size;
    vec3 inv_spacing;
};

uniform uniforms_volume u_volume;

#endif
