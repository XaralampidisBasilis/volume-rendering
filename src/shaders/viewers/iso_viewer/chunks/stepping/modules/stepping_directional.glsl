
// SPACING_DIRECTIONAL
/**
 * Calculates the ray spacing as the mean value of ray depths for all parallel rays 
 * intersecting a voxel's axis-aligned bounding box (aabb).
 *
 * @input volume.inv_spacing    : The inverse of the volume's voxel spacing in each direction (vec3)
 * @input ray.step_direction           : The normalized direction vector of the ray (vec3)
 * @input raymarch.min_step_scale  : The minimum allowable stepping factor (float)
 * @input raymarch.max_step_scale  : The maximum allowable stepping factor (float)
 *
 * @output ray.step_distance            : The computed ray spacing as the mean depth for voxel AABB intersections (float)
 * @output ray.min_spacing        : The minimum ray spacing based on the computed spacing (float)
 * @output ray.max_step_distance        : The maximum ray spacing based on the computed spacing (float)
 */

// compute the adjusted direction by scaling the ray's absolute direction with the inverse spacing of the volume.
vec3 directional_spacing = abs(ray.step_direction) * volume.inv_spacing;

// calculate the ray spacing as the mean value of ray depths from all parallel rays intersecting the voxel aabb.
ray.step_distance = 1.0 / sum(directional_spacing);

// adjust the ray step_distance using the minimum and maximum stepping factors.
ray.min_step_distance = ray.step_distance * raymarch.min_step_scale;
ray.max_step_distance = ray.step_distance * raymarch.max_step_scale;

// coumpute the maximum allowed number of steps based on min step distance
ray.max_step_count = int(ceil(ray.span_distance / ray.min_step_distance));
ray.max_step_count = min(ray.max_step_count, raymarch.max_step_count);
