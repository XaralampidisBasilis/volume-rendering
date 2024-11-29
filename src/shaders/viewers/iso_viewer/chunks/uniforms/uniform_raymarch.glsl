#ifndef UNIFORM_RAYMARCH
#define UNIFORM_RAYMARCH

// struct to hold raycast uniforms
struct Raymarch 
{
    float sample_threshold;   
    float min_step_scaling;     
    float max_step_scaling;     
    float max_step_stretching;     
    int   max_step_count;     
    int   max_skip_count;   
};

uniform Raymarch u_raymarch;

#endif // UNIFORM_RAYMARCH