
// SPACING_DIRECTIONAL
/**
 * Calculates the ray spacing as the mean value of ray depths for all parallel rays 
 * intersecting a voxel's axis-aligned bounding box (aabb).
 *
 * @input u_volume.inv_spacing    : The inverse of the volume's voxel spacing in each direction (vec3)
 * @input ray.step_direction           : The normalized direction vector of the ray (vec3)
 * @input u_rendering.min_step_scaling  : The minimum allowable stepping factor (float)
 * @input u_rendering.max_step_scaling  : The maximum allowable stepping factor (float)
 *
 * @output ray.step_distance            : The computed ray spacing as the mean depth for voxel AABB intersections (float)
 * @output ray.min_spacing        : The minimum ray spacing based on the computed spacing (float)
 * @output ray.max_step_distance        : The maximum ray spacing based on the computed spacing (float)
 */

// compute the adjusted direction by scaling the ray's absolute direction with the inverse spacing of the u_volume.
vec3 directional_spacing = abs(ray.step_direction) * u_volume.inv_spacing;

// calculate the ray spacing as the mean value of ray depths from all parallel rays intersecting the voxel aabb.
ray.step_distance = 1.0 / sum(directional_spacing);
// ray.step_distance = mmin(u_volume.spacing);

// adjust the ray step_distance using the minimum and maximum stepping factors.
ray.min_step_distance = ray.step_distance * u_rendering.min_step_scaling;
ray.max_step_distance = ray.step_distance * u_rendering.max_step_scaling;
