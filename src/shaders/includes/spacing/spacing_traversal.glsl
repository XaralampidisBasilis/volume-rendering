/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray bounds.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3: The stride vector for stepping through the volume along the ray.
 */
float spacing_traversal(in vec3 volume_dimensions, in float ray_span) 
{
    // Find the maximum dimension of the volume to ensure proper scaling.
    float dimension_max = max(volume_dimensions.x, max(volume_dimensions.y, volume_dimensions.z));
    
    // Determine the number of steps the ray should take, based on the resolution and maximum dimension.
    float num_steps = ceil(ray_span * dimension_max);
    
    // Calculate the distance covered in each step.
    float spacing = ray_span / num_steps;

    // Clamp ray delta to a minimum value.
    float ray_spacing = max(spacing, 0.01 / dimension_max);
    
    return ray_spacing;
}
