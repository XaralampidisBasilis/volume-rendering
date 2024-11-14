#ifndef STRUCT_RAY
#define STRUCT_RAY

// struct to hold ray parameters and settings for raymarching
struct Ray 
{
    bool  intersected;          // flag indicating if the ray intersected an object
    bool  terminated;           // flag indicating if the ray has reached out of bounds
    bool  suspended;             // flag indicating if the ray has reached the max step count

    vec3  camera_direction;
    vec3  step_direction;       // direction vector for each step along the ray
    float step_distance;        // fixed step distance for each ray 
    float rand_distance;        // random distance for dithering
   
    vec3  camera_position;      // origin position of the current ray in 3d model coordinates 
    vec3  start_position;       // starting position of the current ray in 3d model coordinates for raymarching
    vec3  end_position;         // ending position of the current ray in 3d model coordinates for raymarching
    float start_distance;       // starting distance along the current ray from origin for raymarching
    float end_distance;         // ending distance along the current ray from origin for raymarching
    float span_distance;        // total distance that can be covered by the current ray for raymarching

    int   skip_count;
    int   max_step_count;       // maximum number of steps allowed
    int   max_skip_count;       // maximum number of skips allowed
    float min_step_scaling;     // minimum step scaling for adaptive stepping
    float max_step_scaling;     // maximum step scaling for adaptive stepping
    float min_step_distance;    // minimum step distance for adaptive stepping
    float max_step_distance;    // maximum step distance for adaptive stepping
  
    vec3  box_start_position;   // minimum allowed starting distance for current ray due to u_volume box
    vec3  box_end_position;     // maximum allowed ending distance for current ray due to u_volume box
    float box_start_distance;   // minimum allowed starting distance for current ray due to u_volume box
    float box_end_distance;     // maximum allowed ending distance for current ray due to u_volume box
    float box_span_distance;    // maximum allowed span distance for current ray due to u_volume box
    vec3  box_min_position;     // min allowed position across all rays due to u_volume box, in 3d model coordinates
    vec3  box_max_position;     // max allowed position across all rays due to u_volume box, in 3d model coordinates
    
    float min_start_distance;   // min allowed distance across all rays due to u_volume box, in 3d model coordinates
    float max_end_distance;     // max allowed distance across all rays due to u_volume box, in 3d model coordinates
    float max_span_distance;    // max allowed distance across all rays due to u_volume box, in 3d model coordinates
};
Ray set_ray()
{
    Ray ray;
    ray.intersected        = false;
    ray.terminated         = false;
    ray.suspended          = false;
    ray.camera_direction   = vec3(0.0);
    ray.step_direction     = vec3(0.0);
    ray.step_distance      = 0.0;
    ray.rand_distance      = 0.0;
    ray.camera_position    = vec3(0.0);
    ray.start_position     = vec3(0.0);
    ray.end_position       = vec3(0.0);
    ray.start_distance     = 0.0;
    ray.end_distance       = 0.0;
    ray.span_distance      = 0.0;
    ray.skip_count         = 0;
    ray.max_step_count     = 0;
    ray.max_skip_count     = 0;
    ray.min_step_scaling   = 0.0;
    ray.max_step_scaling   = 0.0;
    ray.min_step_distance  = 0.0;
    ray.max_step_distance  = 0.0;
    ray.box_start_distance = 0.0;
    ray.box_end_distance   = 0.0;
    ray.box_span_distance  = 0.0;
    ray.box_start_position = vec3(0.0);
    ray.box_end_position   = vec3(0.0);
    ray.box_min_position   = vec3(0.0);
    ray.box_max_position   = vec3(0.0);
    ray.min_start_distance = 0.0;
    ray.max_end_distance   = 0.0;
    ray.max_span_distance  = 0.0;
    return ray;
}
#endif // STRUCT_RAY
