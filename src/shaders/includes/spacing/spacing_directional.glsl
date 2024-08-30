
/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray normal direction
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
float spacing_directional
(
    in vec3 volume_spacing, 
    in vec3 ray_direction
) 
{
    // compute the voxel box 
    vec3 voxel_min = vec3(0.0);
    vec3 voxel_max = volume_spacing;

    // find the ray delta inside the voxel box
    float ray_spacing = intersect_box_max(voxel_min, voxel_max, voxel_min, abs(ray_direction));

    return ray_spacing;
}
