#ifndef UNIFORM_RAYMARCH
#define UNIFORM_RAYMARCH

// struct to hold raycast uniforms
struct Raymarch 
{
    float sample_threshold;   
    float gradient_threshold; 
    float min_step_scale;     
    float max_step_scale;     
    int   max_step_count;     
    int   max_skip_count;   
    int   min_skip_lod;
    int   max_skip_lod;
    int   debug_option;  
};

#endif // UNIFORM_RAYMARCH