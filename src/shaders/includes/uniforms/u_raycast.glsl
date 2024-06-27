#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

uniform highp sampler2D u_raycast_noise;
uniform highp float u_raycast_threshold;  
uniform lowp float u_raycast_refinements;  
uniform lowp float u_raycast_dithering;

// struct to hold raycast uniforms
struct raycast_uniforms 
{
    highp sampler2D noise;
    highp float threshold;  
    lowp float refinements;  
    lowp float dither; 
};

// function to set light uniforms struct
raycast_uniforms set_raycast_uniforms() 
{
    raycast_uniforms u_raycast;

    u_raycast.noise    = u_raycast_noise;
    u_raycast.threshold   = u_raycast_threshold;
    u_raycast.refinements = u_raycast_refinements;
    u_raycast.dither      = u_raycast_dithering;
 
    return u_raycast;
}

#endif