#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

// struct to hold raycast uniforms
struct uniforms_raycast 
{
    float threshold;  
    float refinements;  
    float resolution;
    int stride;
    float dither; 
};

uniform uniforms_raycast u_raycast;

#endif