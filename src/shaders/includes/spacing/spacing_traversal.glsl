/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray bounds.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3: The stride vector for stepping through the volume along the ray.
 */
float spacing_traversal
(
    in vec3 volume_spacing,
    in vec3 volume_dimensions, 
    in float ray_span
) 
{
    // Find the maximum dimension of the volume to ensure proper scaling.
    float dimension_max = max(volume_dimensions.x, max(volume_dimensions.y, volume_dimensions.z));
    float spacing_min = min(volume_spacing.x, min(volume_spacing.y, volume_spacing.z));

    // Calculate the distance covered in each step.
    float ray_spacing = max(ray_span / dimension_max, spacing_min);
    
    return ray_spacing;
}
