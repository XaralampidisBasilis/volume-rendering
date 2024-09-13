
/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray normal direction
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */

vec3 adjusted_direction = abs(ray.direction) * u_volume.inv_spacing;
ray.spacing = 1.0 / sum(adjusted_direction);
ray.min_spacing = ray.spacing * u_raycast.min_stepping;
ray.max_spacing = ray.spacing * u_raycast.max_stepping;