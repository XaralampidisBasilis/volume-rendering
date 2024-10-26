
// SPACING_DIRECTIONAL
/**
 * Calculates the ray spacing as the mean value of ray depths for all parallel rays 
 * intersecting a voxel's axis-aligned bounding box (aabb).
 *
 * @input u_volume.inv_spacing    : The inverse of the volume's voxel spacing in each direction (vec3)
 * @input ray.direction           : The normalized direction vector of the ray (vec3)
 * @input u_raycast.min_stepping  : The minimum allowable stepping factor (float)
 * @input u_raycast.max_stepping  : The maximum allowable stepping factor (float)
 *
 * @output ray.spacing            : The computed ray spacing as the mean depth for voxel AABB intersections (float)
 * @output ray.min_spacing        : The minimum ray spacing based on the computed spacing (float)
 * @output ray.max_spacing        : The maximum ray spacing based on the computed spacing (float)
 */

// compute the adjusted direction by scaling the ray's absolute direction with the inverse spacing of the volume.
vec3 directional_spacing = abs(ray.step_direction) * volume.inv_spacing;

// calculate the ray spacing as the mean value of ray depths from all parallel rays intersecting the voxel aabb.
ray.step_distance = 1.0 / sum(directional_spacing);

// adjust the ray step_distance using the minimum and maximum stepping factors.
ray.min_step_distance = ray.step_distance * raymarch.min_step_scale;
ray.max_step_distance = ray.step_distance * raymarch.max_step_scale;
