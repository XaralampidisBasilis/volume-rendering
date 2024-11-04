
// SPACING_EQUALIZED
/**
 * Calculates the ray spacing for equalized stepping in each direction, 
 * based on the volume's dimensions and spacing.
 *
 * @input volume.dimensions     : The dimensions of the volume (vec3)
 * @input volume.spacing        : The spacing of the volume's voxels (vec3)
 * @input ray.span_distance           : The maximum depth of the ray (float)
 * @input raymarch.min_step_scaling  : The minimum allowable stepping factor (float)
 * @input raymarch.max_step_scaling  : The maximum allowable stepping factor (float)
 *
 * @output ray.step_distance            : The computed ray spacing as the mean depth for voxel AABB intersections (float)
 * @output ray.min_spacing        : The minimum ray spacing based on the computed spacing (float)
 * @output ray.max_step_distance        : The maximum ray spacing based on the computed spacing (float)
 */

// find the maximum steps of the ray to ensure proper scaling.
float max_step_count = mmax(vec3(volume.dimensions));

// find the minimum spacing of the volume's voxels.
float min_step_distance = mmin(volume.spacing);

// calculate the ray spacing by dividing the ray's max depth with the max steps,
// ensure that the spacing is not bellow the minimum allowed value
ray.step_distance = max(ray.span_distance / max_step_count, min_step_distance);

// adjust the ray step_distance using the minimum and maximum stepping factors.
ray.min_step_distance = ray.step_distance * raymarch.min_step_scaling;
ray.max_step_distance = ray.step_distance * raymarch.max_step_scaling;
