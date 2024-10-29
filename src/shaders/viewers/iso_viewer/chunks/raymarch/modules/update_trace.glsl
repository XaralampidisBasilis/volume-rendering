
// Update ray position for the next step
#include "../../stepping/compute_stepping"
trace.step_distance = trace.step_scaling * ray.step_distance;
trace.distance += trace.step_distance;
trace.position += ray.step_direction * trace.step_distance;
trace.voxel_texture_coords = trace.position * volume.inv_size;
trace.voxel_coords = floor(trace.position * volume_inv_spacing);