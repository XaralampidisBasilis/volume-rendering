
// compute block min and max positions in space
vec3 block_min_position = vec3(occumap.block_coords + 0);
vec3 block_max_position = vec3(occumap.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// reverse trace to the start of the block and a bit before
float trace_backstep_distance = intersect_box_max(block_min_position, block_max_position, trace.position, -ray.step_direction);
trace_backstep_distance += u_volume.spacing_length * u_debugger.variable2;  

// take a backstep 
trace.distance -= trace_backstep_distance;
trace.distance = max(trace.distance, ray.box_start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// sample trace
#include "../sample_trace"

// update parameters
trace.spanned_distance -= trace_backstep_distance;
trace.skipped_distance -= trace_backstep_distance;
trace.stepped_distance -= trace.step_distance;
