#ifndef PARAMETERS_RAY
#define PARAMETERS_RAY

// struct to hold gradient uniforms
struct parameters_ray 
{
    vec3  start_position;
    vec3  step_direction;
    float step_size;
    float min_step_size;
    float max_step_size;
    float dither_step;
    float min_distance;
    float max_distance;
    float max_depth;
    vec3  global_min_position;
    vec3  global_max_position;
    float global_min_distance;
    float global_max_distance;
    float global_max_depth;
    int   max_steps;
    int   max_skips;
    bool  intersected;
};

void set(out parameters_ray ray)
{
    ray.origin              = vec3(0.0);
    ray.direction           = vec3(0.0);
    ray.spacing             = 0.0;
    ray.dithering           = 0.0;
    ray.min_distance        = 0.0;
    ray.max_distance        = 0.0;
    ray.max_depth           = 0.0;
    ray.global_min_position = vec3(0.0);
    ray.global_max_position = vec3(0.0);
    ray.global_min_distance = 0.0;
    ray.global_max_distance = 0.0;
    ray.global_max_depth    = 0.0;
    ray.min_spacing         = 0.0;
    ray.max_spacing         = 0.0;
    ray.max_steps           = 0;
    ray.intersected         = false;
}

#endif