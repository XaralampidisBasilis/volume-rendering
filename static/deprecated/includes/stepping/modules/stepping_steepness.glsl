/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float stepping_steepness
(
    in uniforms_raycast u_raycast,
    in uniforms_gradient u_gradient,
    in parameters_ray ray,
    in parameters_trace trace
)
{
    // Interpolate the resolution based on the alignment.
    // when alignment is high, use higher resolution, when low, use lower resolution.
    float steepness = map(u_gradient.min_norm, u_gradient.max_norm, trace.gradient_norm);
    float stepping = mix(u_raycast.max_stepping, u_raycast.min_stepping, steepness);

    return stepping;
}
