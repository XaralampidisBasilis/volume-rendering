#ifndef UNIFORM_RAYCAST
#define UNIFORM_RAYCAST

// struct to hold raycast uniforms
struct Raymarch 
{
    float threshold;  
    float min_stepping;
    float max_stepping;
    int max_steps;
};

#endif