#ifndef RAYCAST_UNIFORMS
#define RAYCAST_UNIFORMS

// struct to hold raycast uniforms
struct uniforms_raycast 
{
    float threshold;  
    float min_stepping;
    float max_stepping;
    float dithering_scale;
    int max_steps;
    int spacing_method;
    int stepping_method;
    int dithering_method;
    int refinement_method;
};

uniform uniforms_raycast u_raycast;

#endif