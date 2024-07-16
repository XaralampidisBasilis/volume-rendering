
/**
 * Calculates the isotropic stride (step vector) for raycasting through a volume 
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray_normal: Normalized direction vector of the ray.
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 step_isotropic(in uniforms_raycast u_raycast, in uniforms_volume u_volume, in vec3 ray_normal) 
{
    float voxel_delta = 0.1 * length(u_volume.voxel);
    float ray_delta = voxel_delta / u_raycast.resolution;

    // Return the stride vector by scaling the ray's direction vector by the step distance
    return ray_delta * ray_normal;
}
