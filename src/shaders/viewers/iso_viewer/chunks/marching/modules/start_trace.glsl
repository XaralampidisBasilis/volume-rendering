// start count
trace.step_count = 0;
trace.skip_count = 0;

// start position
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// sample trace
#include "./sample_trace"

// prepare for next step
#include "./prepare_trace" 
