#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

// struct to hold raycast uniforms
struct uniforms_raycast 
{
    float threshold;  
    int refinements;  
    float resolution;
    int method;
    float dither; 
};

uniform uniforms_raycast u_raycast;

#endif