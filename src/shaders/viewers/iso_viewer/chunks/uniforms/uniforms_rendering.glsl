#ifndef UNIFORMS_RENDERING
#define UNIFORMS_RENDERING

struct Rendering 
{
    float threshold_value;   
    float min_step_scaling;     
    float max_step_scaling;     
    int   max_step_count;     
    int   max_skip_count;   
};

uniform Rendering u_rendering;

#endif // UNIFORMS_RENDERING