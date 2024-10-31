
// compute step scaling
#include "../../scaling/compute_scaling"

// update trace step distance
trace.step_distance = trace.step_scaling * ray.step_distance;
trace.stepped_distance += trace.step_distance;
trace.spanned_distance += trace.step_distance;

// update trace position
trace.distance += trace.step_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance; // prefered to avoid cumulation of numerical errors
// trace.position += trace.step_distance * ray.step_direction; // accumulates numerical errors
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;
