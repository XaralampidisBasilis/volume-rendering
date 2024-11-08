// compute step sclaling factor based on gradients
#include "./compute_trace_step_scaling"

// compute step stretching factor based on distance
#include "./compute_trace_step_streching"

// update trace step distance
trace.step_distance = ray.step_distance * trace.step_scaling * trace.step_stretching;
trace.step_distance = clamp(ray.min_step_distance, ray.max_step_distance, trace.step_distance);

// update trace position
trace.distance += trace.step_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance; // trace.position += trace.step_distance * ray.step_direction; // accumulates numerical errors
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
