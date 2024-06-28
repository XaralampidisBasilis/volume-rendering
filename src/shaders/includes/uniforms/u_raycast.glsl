#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

uniform float u_raycast_threshold;  
uniform float u_raycast_refinements;  
uniform float u_raycast_dither;
uniform float u_raycast_resolution;

// struct to hold raycast uniforms
struct raycast_uniforms 
{
    float threshold;  
    float refinements;  
    float dither; 
    float resolution;
};


#endif