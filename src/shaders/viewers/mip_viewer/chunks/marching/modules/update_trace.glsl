
trace.step_count++;

// update position
trace.distance += trace.step_distance;
trace.position = ray.camera_position + ray.step_direction * trace.distance; 
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// update sample
#include "./update_trace_sample" 
#include "./update_trace_step" 
#include "./update_trace_states" 

// update max trace
if (max_trace.sample_value < trace.sample_value) max_trace = trace;
