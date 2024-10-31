// save trace
trace_prev = trace;

// update trace step distance
#include "../../scaling/compute_scaling"
trace.step_distance = trace.step_scaling * ray.step_distance;
trace.stepped_distance += trace.step_distance;
trace.spanned_distance += trace.step_distance;

// update trace position
trace.distance += trace.step_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance; // trace.position += trace.step_distance * ray.step_direction; // accumulates numerical errors
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// terminate trace
if (trace.distance > ray.end_distance) break;