// compute step stretching factor based on distance
#if TRACE_STEP_STRETCHING_ENABLED == 1
#include "./compute_trace_step_stretching"
#endif

// compute step sclaling factor based on gradients
#if TRACE_STEP_SCALING_ENABLED == 1
#include "./compute_trace_step_scaling"
#endif

// update step distance
trace.step_distance = ray.step_distance * trace.step_scaling;
trace.mean_step_scaling += trace.step_scaling;
trace.mean_step_distance += trace.step_distance;
trace.step_count++;

// update position
trace.distance += trace.step_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance; // trace.position += trace.step_distance * ray.step_direction; // accumulates numerical errors
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
trace.stepped_distance += trace.step_distance;
trace.spanned_distance += trace.step_distance;

// update sample
#include "./sample_trace" 
