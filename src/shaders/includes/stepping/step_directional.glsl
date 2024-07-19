
/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray normal direction
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray_normal: Normalized direction vector of the ray.
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 step_directional(in uniforms_raycast u_raycast, in uniforms_volume u_volume, in vec3 ray_normal) 
{
    // compute the voxel box 
    vec3 voxel_min = vec3(0.0);
    vec3 voxel_max = 1.0 / u_volume.dimensions;

    // find the ray delta inside the voxel box
    float ray_delta = intersect_box_max(voxel_min, voxel_max, voxel_min, abs(ray_normal));
    ray_delta = ray_delta / u_raycast.resolution;

    // Return the stride vector by scaling the ray's direction vector by the step distance
    return ray_delta * ray_normal;
}
