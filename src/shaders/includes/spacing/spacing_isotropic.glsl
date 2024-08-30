
/**
 * Calculates the isotropic stride (step vector) for raycasting through a volume 
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
float spacing_isotropic(in vec3 volume_spacing)
{
    float ray_spacing = min(volume_spacing.x, min(volume_spacing.y, volume_spacing.z));

    return ray_spacing;
}
