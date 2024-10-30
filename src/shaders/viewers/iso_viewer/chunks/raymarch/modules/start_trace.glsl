trace.block_lod = occumap.lod;

// take a backstep in order to compute the previouse trace 
trace.distance -= ray.min_step_distance;
trace.position -= ray.min_step_distance * ray.step_direction;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// sample the volume at previous step and save the trace
#include "./sample_volume"
trace_prev = trace;

// take a frontstep to get in the starting position
trace.distance += ray.min_step_distance;
trace.position += ray.min_step_distance * ray.step_direction;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;

// distances
trace.step_distance = ray.min_step_distance;
trace.step_scaling = 1.0;
trace.stepped_distance = 0.0;
