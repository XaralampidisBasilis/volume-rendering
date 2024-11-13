// start count
trace.step_count = 0;
trace.skip_count = 0;

// start position
trace.distance = ray.start_distance;
trace.position = ray.start_position;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

#include "./sample_trace"

// compute step stretching 
#if TRACE_STEP_STRETCHING_ENABLED == 1
#include "./compute_trace_step_stretching"
#endif

// compute step sclaling
#if TRACE_STEP_SCALING_ENABLED == 1
#include "./compute_trace_step_scaling"
#endif

// update trace step distance
trace.step_distance = ray.step_distance * trace.step_scaling;
trace.mean_step_scaling += trace.step_scaling;
trace.mean_step_distance += trace.step_distance;