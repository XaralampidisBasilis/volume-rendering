// start count
trace.step_count = 0;
trace.skip_count = 0;

// start step scaling
trace.min_step_scaling = ray.min_step_scaling;
trace.max_step_scaling = ray.max_step_scaling;

// start position
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// update trace sample
#include "./update_trace_sample"
#include "./update_trace_step"
#include "./update_trace_states"
#include "./start_trace_previous"
