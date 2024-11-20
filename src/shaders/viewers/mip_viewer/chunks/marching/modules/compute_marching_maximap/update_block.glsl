// trace.skip_count++;

// compute block min and max positions in space
vec3 block_min = vec3(trace.block_coords + 0) - MILLI_TOLERANCE;
vec3 block_max = vec3(trace.block_coords + 1) + MILLI_TOLERANCE;
block_min *= u_maximap.spacing;
block_max *= u_maximap.spacing;

// find block skip distance in order to exit the block
float skip_distance = intersect_box_max(block_min, block_max, trace.position, ray.step_direction);

// update trace
trace.distance += skip_distance;
trace.position = ray.camera_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// do not take next step 
trace.step_distance = 0.0;

// update states
#include "../update_trace_states" 
