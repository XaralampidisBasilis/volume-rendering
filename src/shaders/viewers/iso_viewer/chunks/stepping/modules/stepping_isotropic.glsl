
// SPACING_ISOTROPIC
/**
 * Calculates the isotropic ray step distance for raycasting through a volume.
 * This method ensures uniform ray step distance in all directions by using the smallest 
 * voxel step distance in the volume.
 *
 * @input volume.spacing          : The voxel step_distance in each direction of the volume (vec3)
 * @input raymarch.min_step_scale : The minimum allowable step scaling factor (float)
 * @input raymarch.max_step_scale : The maximum allowable step scaling factor (float)
 *
 * @output ray.step_distance      : The isotropic ray step distance based on the smallest voxel step distance (float)
 * @output ray.min_step_distance  : The minimum ray step distance based on the min step sclaing factor (float)
 * @output ray.max_step_distance  : The maximum ray step distance based on the max step sclaing factor (float)
 */

// calculate the isotropic ray spacing by taking the smallest voxel spacing in the volume.
ray.step_distance = mmin(volume.spacing);

// adjust the ray step_distance using the minimum and maximum stepping factors.
ray.min_step_distance = ray.step_distance * raymarch.min_step_scale;
ray.max_step_distance = ray.step_distance * raymarch.max_step_scale;
