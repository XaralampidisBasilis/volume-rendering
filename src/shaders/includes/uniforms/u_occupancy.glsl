#ifndef OCCUPANCY_UNIFORMS
#define OCCUPANCY_UNIFORMS

uniform highp sampler2D u_occupancy_data;
uniform mediump vec3 u_occupancy_size;
uniform mediump vec3 u_occupancy_block;

// struct to hold occupancy uniforms
struct occupancy_uniforms 
{
    highp sampler2D data;
    highp float size;  
    lowp float block;  
};

// function to set light uniforms struct
occupancy_uniforms set_occupancy_uniforms() 
{
    occupancy_uniforms u_occupancy;

    u_occupancy.data  = u_occupancy_data;
    u_occupancy.size  = u_occupancy_size;
    u_occupancy.block = u_occupancy_block;
 
    return u_occupancy;
}

#endif