#ifndef PARAMETERS_RAY
#define PARAMETERS_RAY

// struct to hold gradient uniforms
struct parameters_ray 
{
    vec3  origin;
    vec3  direction;
    float spacing;
    float dithering;
    float min_distance;
    float max_distance;
    float max_depth;
    vec3  global_min_position;
    vec3  global_max_position;
    float global_min_distance;
    float global_max_distance;
    float global_max_depth;
    float min_spacing;
    float max_spacing;
    int   max_steps;
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