#ifndef PARAMETERS_RAY
#define PARAMETERS_RAY

// struct to hold gradient uniforms
struct parameters_ray 
{
    vec3  origin;
    vec3  direction;
    vec3  box_min;
    vec3  box_max;
    float spacing;
    float dithering;
    float min_distance;
    float max_distance;
    float max_depth;
    float min_box_distance;
    float max_box_distance;
    float max_box_depth;
    float min_spacing;
    float max_spacing;
    int   max_steps;
    bool  intersected;
};

void set_ray(out parameters_ray ray)
{
    ray.origin           = vec3(0.0);
    ray.direction        = vec3(0.0);
    ray.box_min          = vec3(0.0);
    ray.box_max          = vec3(0.0);
    ray.spacing          = 0.0;
    ray.dithering        = 0.0;
    ray.min_distance     = 0.0;
    ray.max_distance     = 0.0;
    ray.max_depth        = 0.0;
    ray.min_box_distance = 0.0;
    ray.max_box_distance = 0.0;
    ray.max_box_depth    = 0.0;
    ray.min_spacing      = 0.0;
    ray.max_spacing      = 0.0;
    ray.max_steps        = 0;
    ray.intersected      = false;
}

#endif