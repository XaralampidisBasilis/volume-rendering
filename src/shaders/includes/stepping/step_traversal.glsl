/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray bounds.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3: The stride vector for stepping through the volume along the ray.
 */
vec3 step_traversal
(
    in uniforms_volume u_volume, 
    inout parameters_ray ray
) 
{
    // Find the maximum dimension of the volume to ensure proper scaling.
    float dimension_max = max(u_volume.dimensions.x, max(u_volume.dimensions.y, u_volume.dimensions.z));
    
    // Determine the number of steps the ray should take, based on the resolution and maximum dimension.
    float num_steps = ceil(ray.span * dimension_max);
    
    // Calculate the distance covered in each step.
    float ray_delta = ray.span / num_steps;

    // Clamp ray delta to a minimum value.
    ray_delta = max(ray_delta, 0.01 / dimension_max);

    // Update the ray's step and return the stride vector by scaling the ray's direction vector by the step distance.
    vec3 ray_step = ray_delta * ray.direction;
    
    return ray_step;
}
