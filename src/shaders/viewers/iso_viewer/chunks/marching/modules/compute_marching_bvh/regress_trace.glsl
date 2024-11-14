occumap.block_coords = ivec3(trace.position * occumap.inv_spacing);

// compute final occupied block bounds in model space
vec3 block_min_position = vec3(occumap.block_coords + 0);
vec3 block_max_position = vec3(occumap.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// an occupied block is occupied also half a voxel outside due to trilinear filtering
block_min_position -= u_volume.spacing * 0.5;
block_max_position += u_volume.spacing * 0.5;

// compute the distance to get to the start of the occupied block
float trace_backstep = intersect_box_max(block_min_position, block_max_position, trace.position, -ray.step_direction);
trace_backstep += u_volume.spacing_length * 2.0;

// take a backstep 
trace.distance -= trace_backstep;
trace.distance = max(trace.distance, ray.box_start_distance);
trace.position = ray.camera_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// sample trace
#include "../update_trace_sample"
#include "../update_trace_step" 
#include "../update_trace_states" 

// update parameters
trace.spanned_distance -= trace_backstep;
trace.skipped_distance -= trace_backstep;
trace.stepped_distance -= trace_backstep;

