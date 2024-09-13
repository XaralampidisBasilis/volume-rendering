
/**
 * Calculates the isotropic stride (step vector) for raycasting through a volume 
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */

ray.spacing = mmin(u_volume.spacing);
ray.min_spacing = ray.spacing * u_raycast.min_stepping;
ray.max_spacing = ray.spacing * u_raycast.max_stepping;
