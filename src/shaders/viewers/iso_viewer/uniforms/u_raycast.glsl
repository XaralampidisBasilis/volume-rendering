#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

// struct to hold raycast uniforms
struct raycast_uniforms 
{
    float threshold;  
    float refinements;  
    float resolution;
    int stride;
    float dither; 
};

uniform raycast_uniforms u_raycast;

#endif