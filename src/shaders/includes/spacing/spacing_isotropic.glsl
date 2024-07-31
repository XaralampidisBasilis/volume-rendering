
/**
 * Calculates the isotropic stride (step vector) for raycasting through a volume 
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
float spacing_isotropic(in vec3 volume_dimensions)
{
    vec3 voxel_spacing = 1.0 / volume_dimensions;
    float ray_spacing = min(voxel_spacing.x, min(voxel_spacing.y, voxel_spacing.z));

    // Return the stride vector by scaling the ray's direction vector by the step distance
    return ray_spacing;
}
