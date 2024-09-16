
// SPACING_ISOTROPIC
/**
 * Calculates the isotropic ray spacing for raycasting through a volume.
 * This method ensures uniform ray spacing in all directions by using the smallest 
 * voxel spacing in the volume.
 *
 * @input u_volume.spacing        : The voxel spacing in each direction of the volume (vec3)
 * @input u_raycast.min_stepping  : The minimum allowable stepping factor (float)
 * @input u_raycast.max_stepping  : The maximum allowable stepping factor (float)
 *
 * @output ray.spacing            : The isotropic ray spacing based on the smallest voxel spacing (float)
 * @output ray.min_spacing        : The adjusted minimum ray spacing based on the stepping factor (float)
 * @output ray.max_spacing        : The adjusted maximum ray spacing based on the stepping factor (float)
 */

// calculate the isotropic ray spacing by taking the smallest voxel spacing in the volume.
ray.spacing = mmin(u_volume.spacing);

// adjust the ray spacing using the minimum and maximum stepping factors.
ray.min_spacing = ray.spacing * u_raycast.min_stepping;
ray.max_spacing = ray.spacing * u_raycast.max_stepping;
