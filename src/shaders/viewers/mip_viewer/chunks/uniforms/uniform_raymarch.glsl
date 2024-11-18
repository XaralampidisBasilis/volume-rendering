#ifndef UNIFORM_RAYMARCH
#define UNIFORM_RAYMARCH

// struct to hold raycast uniforms
struct Raymarch 
{
    float step_speed;
    float min_step_scaling;     
    float max_step_scaling;     
    float max_step_stretching;     
    int   max_step_count;     
};

#endif // UNIFORM_RAYMARCH