
// take a backstep 
trace.distance -= trace_backstep;
trace.distance = max(trace.distance, ray.box_start_distance);
trace.position = ray.camera_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texels = trace.position * u_volume.inv_size;

// sample trace
#include "../update_trace_sample"
#include "../update_trace_step" 
#include "../update_trace_states" 

// update parameters
trace.spanned_distance -= trace_backstep;
trace.skipped_distance -= trace_backstep;
trace.stepped_distance -= trace_backstep;

