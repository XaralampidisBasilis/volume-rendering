
/**
 * Calculates the isotropic stride (step vector) for raycasting through a volume 
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 step_isotropic
(
    in uniforms_volume u_volume, 
    in parameters_ray ray
) 
{
    float ray_delta = 0.1 * length(1.0 / u_volume.dimensions);
    vec3 ray_step = ray_delta * ray.direction;

    // Return the stride vector by scaling the ray's direction vector by the step distance
    return ray_step;
}
