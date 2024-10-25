#ifndef UNIFORM_RAYCAST
#define UNIFORM_RAYCAST

// struct to hold raycast uniforms
struct Raycast 
{
    float threshold;  
    float min_stepping;
    float max_stepping;
    int max_steps;
};

#endif