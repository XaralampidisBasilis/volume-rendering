/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray bounds.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3: The stride vector for stepping through the volume along the ray.
 */

// Find the maximum dimension of the volume to ensure proper scaling.
float dimension_max = mmax(u_volume.dimensions);
float spacing_min = mmin(u_volume.spacing);

// Calculate the distance covered in each step.
ray.spacing = max(ray.max_depth / dimension_max, spacing_min);
ray.min_spacing = ray.spacing * u_raycast.min_stepping;
ray.max_spacing = ray.spacing * u_raycast.max_stepping;

