#ifndef VOLUME_UNIFORMS
#define VOLUME_UNIFORMS

uniform highp sampler3D u_volume_data;
uniform lowp sampler3D u_volume_mask;
uniform mediump vec3 u_volume_size;
uniform mediump vec3 u_volume_dimensions;
uniform highp float u_volume_voxel;

// struct to hold volume uniforms
struct volume_uniforms 
{
    highp sampler3D data;
    lowp sampler3D mask;
    mediump vec3 size;
    mediump vec3 dimensions;
    highp float voxel;
};

// function to set volume uniforms struct
volume_uniforms set_volume_uniforms() 
{
    volume_uniforms u_volume;

    u_volume.dimensions = u_volume_dimensions;
    u_volume.size       = u_volume_size;
    u_volume.voxel      = u_volume_voxel;
    u_volume.data       = u_volume_data;
    u_volume.mask       = u_volume_mask;
 
    return u_volume;
}

#endif
