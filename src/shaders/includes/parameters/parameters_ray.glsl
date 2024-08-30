#ifndef PARAMETERS_RAY
#define PARAMETERS_RAY

// struct to hold gradient uniforms
struct parameters_ray 
{
    vec3 origin;
    vec3 direction;
    vec3 step; 
    vec2 bounds;
    float span;
    float dithering;
    float spacing;
    int max_steps;
};

parameters_ray ray;

void set_ray()
{
    ray.origin = vec3(0.0);
    ray.direction = vec3(0.0);
    ray.step = vec3(0.0); 
    ray.bounds = vec2(0.0);
    ray.span = 0.0;
    ray.dithering = 0.0;
    ray.spacing = 0.0;
    ray.max_steps = 0;
}

#endif