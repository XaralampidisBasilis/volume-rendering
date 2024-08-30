#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

// struct to hold raycast uniforms
struct uniforms_raycast 
{
    float threshold;  
    int refinements;  
    float stepping_min;
    float stepping_max;
    int spacing_method;
    int stepping_method;
    int dithering_method;
    float has_dithering; 
    int has_skipping; 
};

uniform uniforms_raycast u_raycast;

#endif