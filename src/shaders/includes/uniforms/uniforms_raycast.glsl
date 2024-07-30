#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

// struct to hold raycast uniforms
struct uniforms_raycast 
{
    float threshold;  
    int refinements;  
    float resolution_min;
    float resolution_max;
    int step_method;
    int dither_method;
    float dithering; 
    int skipping; 
};

uniform uniforms_raycast u_raycast;

#endif