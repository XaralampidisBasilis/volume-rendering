#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

uniform float u_raycast_threshold;  
uniform float u_raycast_refinements;  
uniform float u_raycast_dither;
uniform float u_raycast_resolution;
uniform int u_raycast_stride;

// struct to hold raycast uniforms
struct raycast_uniforms 
{
    float threshold;  
    float refinements;  
    float dither; 
    float resolution;
    int stride;
};


#endif