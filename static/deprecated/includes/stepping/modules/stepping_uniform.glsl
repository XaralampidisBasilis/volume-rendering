/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float stepping_uniform
(
    in uniforms_raycast u_raycast,
    in parameters_ray ray,
    in parameters_trace trace
)
{
    // Interpolate the resolution based on the alignment.
    // when alignment is high, use higher resolution, when low, use lower resolution.
    // float stepping = mix(u_raycast.max_stepping, u_raycast.min_stepping, 0.5);
    float stepping = u_raycast.min_stepping;

    return stepping;
}
