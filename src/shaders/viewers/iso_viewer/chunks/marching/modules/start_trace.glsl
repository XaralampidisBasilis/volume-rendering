// start count
trace.step_count = 0;
trace.skip_count = 0;

// start position
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// update trace sample
#include "./update_trace_sample"
#include "./update_trace_step"
#include "./update_trace_states"
