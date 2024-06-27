#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

uniform highp sampler2D u_noisemap_data;
uniform highp float u_raycast_threshold;  
uniform lowp float u_raycast_refinements;  
uniform lowp float u_raycast_dithering;

// struct to hold raycast uniforms
struct raycast_uniforms 
{
    highp sampler2D noisemap;
    highp sampler2D occupancy;
    mediump vec3 num_blocks;
    mediump vec3 block_size;
    highp float threshold;  
    lowp float refinements;  
    lowp float dither; 
};

// function to set light uniforms struct
raycast_uniforms set_raycast_uniforms() 
{
    raycast_uniforms u_raycast;

    u_raycast.noisemap    = u_noisemap_data;
    u_raycast.occupancy   = u_occupancy_data;
    u_raycast.num_blocks  = u_occupancy_size;
    u_raycast.block_size  = u_occupancy_block;
    u_raycast.threshold   = u_raycast_threshold;
    u_raycast.refinements = u_raycast_refinements;
    u_raycast.dither      = u_raycast_dithering;
 
    return u_raycast;
}

#endif