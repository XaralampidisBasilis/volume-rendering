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
    float dither;
    float spacing;
    int num_steps;
};

parameters_ray ray;

void set_ray(in vec3 origin, in vec3 direction)
{
    ray.origin = origin;
    ray.direction = direction;
    ray.step = vec3(0.0); 
    ray.bounds = vec2(0.0);
    ray.span = 0.0;
    ray.dither = 0.0;
    ray.spacing = 0.0;
    ray.num_steps = 0;
}

#endif