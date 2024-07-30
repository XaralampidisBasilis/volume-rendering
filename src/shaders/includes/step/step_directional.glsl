
/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray normal direction
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 step_directional
(
    in vec3 volume_dimensions, 
    in vec3 ray_direction
) 
{
    // compute the voxel box 
    vec3 voxel_min = vec3(0.0);
    vec3 voxel_max = 1.0 / volume_dimensions;

    // find the ray delta inside the voxel box
    float ray_delta = intersect_box_max(voxel_min, voxel_max, voxel_min, abs(ray.direction));

    // Return the stride vector by scaling the ray's direction vector by the step distance
    vec3 ray_step = ray_delta * ray_direction;

    return ray_step;
}
