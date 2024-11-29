
trace.step_count++;

// update position
trace_prev.distance = trace.distance;
trace.distance += trace.step_distance;
trace.position = ray.camera_position + ray.step_direction * trace.distance; 
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
trace.stepped_distance += trace.step_distance;
trace.spanned_distance += trace.step_distance;

// update sample
#include "./update_trace_sample" 
#include "./update_trace_step" 
#include "./update_trace_states" 
