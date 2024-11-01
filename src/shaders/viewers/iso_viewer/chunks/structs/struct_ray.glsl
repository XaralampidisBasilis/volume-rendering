#ifndef STRUCT_RAY
#define STRUCT_RAY

// struct to hold ray parameters and settings for raymarching
struct Ray 
{
    bool  intersected;          // flag indicating if the ray intersected an object

    vec3  origin_position;      // origin position of the ray in 3d model coordinates 
    vec3  start_position;       // starting position of the ray in 3d model coordinates for raymarching
    vec3  end_position;         // ending position of the ray in 3d model coordinates for raymarching
    vec3  min_position;         // min allowed position across all rays due to volume size, in 3d model coordinates
    vec3  max_position;         // max allowed position across all rays due to volume size, in 3d model coordinates
    float min_distance;         // min allowed distance across all rays due to volume size, in 3d model coordinates
    float max_distance;         // max allowed distance across all rays due to volume size, in 3d model coordinates

    vec3  step_direction;       // direction vector for each step along the ray
    float step_distance;        // fixed step distance for each ray 
    float rand_distance;        // random distance for dithering
    float start_distance;       // starting distance along the ray from origin for raymarching
    float end_distance;         // ending distance along the ray from origin for raymarching
    float span_distance;        // total distance that can be covered by the ray for raymarching
   
    int   max_step_count;       // maximum number of steps allowed
    int   max_skip_count;       // maximum number of skips allowed

    float min_step_distance;    // minimum step distance for adaptive stepping
    float max_step_distance;    // maximum step distance for adaptive stepping
    float min_start_distance;   // minimum allowed starting distance for each ray due to volume size
    float max_end_distance;     // maximum allowed ending distance for each ray due to volume size
    float max_span_distance;    // maximum allowed span distance for each ray due to volume size
    vec3  min_start_position;   // minimum allowed starting distance for each ray due to volume size
    vec3  max_end_position;     // maximum allowed ending distance for each ray due to volume size

    float max_voxel_distance;   // maximum distance that can be spanned inside a voxel
    float max_block_distance;   // maximum distance that can be spanned inside an occupancy block
};

Ray set_ray()
{
    Ray ray;
    ray.step_direction     = vec3(0.0);
    ray.step_distance      = 0.0;
    ray.min_step_distance  = 0.0;
    ray.max_step_distance  = 0.0;
    ray.max_step_count     = 0;
    ray.max_skip_count     = 0;
    ray.origin_position    = vec3(0.0);
    ray.start_position     = vec3(0.0);
    ray.end_position       = vec3(0.0);
    ray.min_position       = vec3(0.0);
    ray.max_position       = vec3(0.0);
    ray.min_distance       = 0.0;
    ray.max_distance       = 0.0;
    ray.rand_distance      = 0.0;
    ray.start_distance     = 0.0;
    ray.end_distance       = 0.0;
    ray.span_distance      = 0.0;
    ray.min_start_distance = 0.0;
    ray.max_end_distance   = 0.0;
    ray.max_span_distance  = 0.0;
    ray.min_start_position = vec3(0.0);
    ray.max_end_position   = vec3(0.0);
    ray.min_distance       = 0.0;
    ray.max_distance       = 0.0;
    ray.max_voxel_distance = 0.0;
    ray.max_block_distance = 0.0;
    ray.intersected        = false;
    return ray;
}

#endif // STRUCT_RAY
