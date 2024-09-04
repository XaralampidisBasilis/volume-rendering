#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

// struct to hold raycast uniforms
struct uniforms_raycast 
{
    float threshold;  
    int refinements;  
    float min_stepping;
    float max_stepping;
    int max_steps;
    int spacing_method;
    int stepping_method;
    int dithering_method;
    float has_dithering; 
    int has_skipping; 
    float has_bbox;
};

uniform uniforms_raycast u_raycast;

#endif