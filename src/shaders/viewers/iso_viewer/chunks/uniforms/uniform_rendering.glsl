#ifndef UNIFORM_RENDERING
#define UNIFORM_RENDERING

// struct to hold raycast uniforms
struct Rendering 
{
    float min_value;   
    float min_step_scaling;     
    float max_step_scaling;     
    int   max_step_count;     
    int   max_skip_count;   
};

uniform Rendering u_rendering;

#endif // UNIFORM_RENDERING