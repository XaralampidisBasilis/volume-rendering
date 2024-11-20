#ifndef STRUCT_TRACE
#define STRUCT_TRACE

// struct to hold information about the current ray trace 
struct Trace 
{
    bool  terminated;           // flag indicating if the trace has reached out of u_volume bounds
    bool  suspended;            // flag indicating if the trace has reached the max step count
    bool  update;               // flag indicating if the trace can continue marching

    int   step_count;           // number of steps taken along the ray
    float step_distance;        // distance to be covered
    float step_scaling;         // scaling factor for step size
    float rand_distance;        // random distance for dithering

    vec3  position;             // current position in 3d model coordinates
    float distance;             // current distance traveled from camera
    ivec3 voxel_coords;         // integer voxel coordinates in 3d space
    vec3  voxel_texture_coords; // normalized voxel texture coordinates

    vec4  sample_data;          // sampled data at the current position
    float sample_value;         // sampled value at the current position
    
    vec3  gradient;             // gradient vector
    vec3  gradient_direction;   // direction of the gradient vector
    float gradient_magnitude;   // magnitude of the gradient vector
    float derivative;           // directional derivative at the sample position

    vec4  mapped_color;         // color mapped from the sample value

    ivec3 block_coords;     // integer voxel coordinates in 3d space
    float block_min_value;  // integer voxel coordinates in 3d space
    float block_max_value;  // integer voxel coordinates in 3d space
    bool  block_occupied;   // integer voxel coordinates in 3d space

};

Trace set_trace()
{
    Trace trace;
    trace.terminated = false;
    trace.suspended = false;
    trace.update = true;
    trace.step_count = 0;
    trace.step_scaling = 0.0;      
    trace.step_distance = 0.0;
    trace.rand_distance = 0.0;
    trace.position = vec3(0.0);
    trace.distance = 0.0;
    trace.sample_data = vec4(0.0);
    trace.sample_value = 0.0;
    trace.voxel_coords = ivec3(0);
    trace.voxel_texture_coords = vec3(0.0);
    trace.gradient = vec3(0.0);
    trace.gradient_direction = vec3(0.0);
    trace.gradient_magnitude = 0.0;
    trace.derivative = 0.0;
    trace.mapped_color = vec4(vec3(0.0), 1.0);
    trace.block_coords = ivec3(0);
    trace.block_min_value = 0.0;
    trace.block_max_value = 0.0;
    trace.block_occupied = false;
    return trace;
}

#endif // STRUCT_TRACE
