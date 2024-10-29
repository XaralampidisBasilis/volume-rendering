
trace.step_distance = -ray.step_distance;
trace.distance += trace.step_distance;
trace.position += ray.step_direction * trace.step_distance;
trace.voxel_texture_coords = trace.position * volume.inv_size;

#include "./sample_volume"
trace_prev = trace;

trace.step_distance = +ray.step_distance;
trace.distance += trace.step_distance;
trace.position += ray.step_direction * trace.step_distance;
trace.voxel_texture_coords = trace.position * volume.inv_size;