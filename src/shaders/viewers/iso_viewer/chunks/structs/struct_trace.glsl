#ifndef STRUCT_TRACE
#define STRUCT_TRACE

// struct to hold information about the current ray trace 
struct Trace 
{
    int step_count;             // number of steps taken along the ray
    int skip_count;             // number of skipped steps along the ray

    float step_scaling;         // scaling factor for step size
    float step_distance;        // distance to be covered
    float skip_distance;        // distance to be skipped
    float rand_distance;        // random distance for dithering

    vec3  position;             // current position in 3d model coordinates
    float distance;             // current distance traveled from camera
    float spanned_distance;     // total spanned distance from ray start including stepping and skipping
    float stepped_distance;     // total stepped distance from ray start
    float skipped_distance;     // total skipped distance from ray start

    float sample;               // sampled value at the current position
    float sample_error;         // sampled error associated with the difference of the sample value from the threshold

    ivec3 voxel_coords;         // integer voxel coordinates in 3d space
    vec3  voxel_texture_coords; // normalized voxel texture coordinates

    bool  block_occupied;       // whether the trace's current block is occupied
    ivec3 block_coords;         // integer coordinates of the current block
    vec3  block_texture_coords; // normalized texture coordinates of the block

    vec3  normal;               // normal vector
    vec3  gradient;             // gradient vector
    vec3  gradient_direction;   // direction of the gradient vector
    float gradient_magnitude;   // magnitude of the gradient vector

    float derivative_1st;       // first derivative at the sample position
    float derivative_2nd;       // second derivative at the sample position
    float derivative_3rd;       // third derivative at the sample position

    vec4  mapped_color;         // color mapped from the sample value
    vec4  shaded_color;         // color after shading has been applied
};

Trace Trace()
{
    Trace trace;
    trace.step_count = 0;
    trace.skip_count = 0;
    trace.step_scaling = 1.0;
    trace.step_distance = 0.0;
    trace.skip_distance = 0.0;
    trace.rand_distance = 0.0;
    trace.position = vec3(0.0);
    trace.distance = 0.0;
    trace.spanned_distance = 0.0;
    trace.stepped_distance = 0.0;
    trace.skipped_distance = 0.0;
    trace.sample = 0.0;
    trace.sample_error = 0.0;
    trace.voxel_coords = ivec3(0);
    trace.voxel_texture_coords = vec3(0.0);
    trace.block_occupied = false;
    trace.block_coords = ivec3(0);
    trace.block_texture_coords = vec3(0.0);
    trace.normal = vec3(0.0);
    trace.gradient = vec3(0.0);
    trace.gradient_direction = vec3(0.0);
    trace.gradient_magnitude = 0.0;
    trace.derivative_1st = 0.0;
    trace.derivative_2nd = 0.0;
    trace.derivative_3rd = 0.0;
    trace.mapped_color = vec4(0.0);
    trace.shaded_color = vec4(0.0);
    return trace;
}

#endif // STRUCT_TRACE
