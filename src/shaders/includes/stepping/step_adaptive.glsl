/**
 * Calculates an adaptive stride (step vector) for raycasting through a volume.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray_normal: Normalized direction vector of the ray.
 * @param ray_position: Current position of the ray in the volume.
 * @param min_step: Minimum step distance to avoid very small steps.
 * @param max_step: Maximum step distance to avoid very large steps.
 * @param density_threshold: Threshold for adjusting step size based on local density.
 * @return vec3 The adaptive stride vector for stepping through the volume along the ray.
 */
vec3 step_adaptive(in uniforms_raycast u_raycast, in uniforms_volume u_volume, in vec3 ray_normal, in vec3 ray_position, float min_step, float max_step, float density_threshold) 
{
    // Sample the local density at the current ray position
    float density = texture(u_volume.texture, ray_position).r;

    // Calculate step size based on local density
    float ray_delta = mix(max_step, min_step, smoothstep(0.0, density_threshold, density));

    // Clamp the step size to ensure it's within the min and max step bounds
    ray_delta = clamp(ray_delta, min_step, max_step);

    // Return the stride vector by scaling the ray's direction vector by the step size
    return ray_delta * ray_normal;
}
