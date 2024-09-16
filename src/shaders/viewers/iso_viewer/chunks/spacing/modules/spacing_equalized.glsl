
// SPACING_EQUALIZED
/**
 * Calculates the ray spacing for equalized stepping in each direction, 
 * based on the volume's dimensions and spacing.
 *
 * @input u_volume.dimensions     : The dimensions of the volume (vec3)
 * @input u_volume.spacing        : The spacing of the volume's voxels (vec3)
 * @input ray.max_depth           : The maximum depth of the ray (float)
 * @input u_raycast.min_stepping  : The minimum allowable stepping factor (float)
 * @input u_raycast.max_stepping  : The maximum allowable stepping factor (float)
 *
 * @output ray.spacing            : The computed ray spacing as the mean depth for voxel AABB intersections (float)
 * @output ray.min_spacing        : The minimum ray spacing based on the computed spacing (float)
 * @output ray.max_spacing        : The maximum ray spacing based on the computed spacing (float)
 */

// find the maximum steps of the ray to ensure proper scaling.
float max_steps = mmax(u_volume.dimensions);

// find the minimum spacing of the volume's voxels.
float min_spacing = mmin(u_volume.spacing);

// calculate the ray spacing by dividing the ray's max depth with the max steps,
// ensure that the spacing is not bellow the minimum allowed value
ray.spacing = max(ray.max_depth / max_steps, min_spacing);

// compute the minimum and maximum spacing based on the ray spacing and stepping factors.
ray.min_spacing = ray.spacing * u_raycast.min_stepping;
ray.max_spacing = ray.spacing * u_raycast.max_stepping;
