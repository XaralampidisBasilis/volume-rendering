#ifndef UNIFORM_RAYMARCH
#define UNIFORM_RAYMARCH

// struct to hold raycast uniforms
struct Raymarch 
{
    float min_sample_value;   
    float max_sample_value;   
    float step_speed;
    float min_step_scaling;     
    float max_step_scaling;     
    float max_step_stretching;     
    int   max_step_count;     
    int   max_skip_count;   
    int   min_skip_lod;
    int   max_skip_lod;
};

#endif // UNIFORM_RAYMARCH