
// compute step scaling
#include "../../scaling/compute_scaling"

// update trace step distance
trace.step_distance = trace.step_scaling * ray.step_distance;
trace.stepped_distance += trace.step_distance;

// update trace position
trace.distance += trace.step_distance;
trace.spanned_distance += trace.step_distance;
trace.position += ray.step_direction * trace.step_distance;
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);
trace.voxel_texture_coords = trace.position * volume.inv_size;
