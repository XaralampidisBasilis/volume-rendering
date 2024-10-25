#ifndef STRUCT_RAY
#define STRUCT_RAY

// struct to hold ray parameters and settings for raymarching
struct Ray 
{
    vec3  step_direction;       // direction vector for each step along the ray
    float step_distance;        // fixed step distance for each ray 

    float min_step_distance;    // minimum step distance for adaptive stepping
    float max_step_distance;    // maximum step distance for adaptive stepping

    int   max_step_count;       // maximum number of steps allowed
    int   max_skip_count;       // maximum number of skips allowed

    vec3  start_position;       // starting position of the ray in 3d model coordinates
    vec3  end_position;         // ending position of the ray in 3d model coordinates
    float start_distance;       // starting distance along the ray from camera
    float end_distance;         // ending distance along the ray from camera
    float span_distance;        // total distance that can be covered by the ray
    float rand_distance;        // random distance for dithering

    bool  intersected;          // flag indicating if the ray intersected an object
};

Ray Ray()
{
    Ray ray;
    ray.step_direction = vec3(0.0);
    ray.step_distance = 0.0;
    ray.min_step_distance = 0.0;
    ray.max_step_distance = 0.0;
    ray.max_step_count = 0;
    ray.max_skip_count = 0;
    ray.start_position = vec3(0.0);
    ray.end_position = vec3(0.0);
    ray.start_distance = 0.0;
    ray.end_distance = 0.0;
    ray.span_distance = 0.0;
    ray.rand_distance = 0.0;
    ray.intersected = false;
    return ray;
}

#endif // STRUCT_RAY
