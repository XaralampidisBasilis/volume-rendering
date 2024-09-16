
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
vec3 adjusted_direction = abs(ray.direction) * u_volume.inv_spacing;

// calculate the ray spacing as the mean value of ray depths from all parallel rays intersecting the voxel aabb.
ray.spacing = 1.0 / sum(adjusted_direction);

// compute the minimum and maximum spacing based on the ray spacing and stepping factors.
ray.min_spacing = ray.spacing * u_raycast.min_stepping;
ray.max_spacing = ray.spacing * u_raycast.max_stepping;
