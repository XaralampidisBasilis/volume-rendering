/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float stepping_adaptive
(
    in uniforms_raycast u_raycast,
    in parameters_ray ray,
    in parameters_trace trace
)
{
    float spacing = - trace.error / trace.derivative;
    float stepping = spacing / ray.spacing;
    float is_positive = step(0.0, stepping);
    
    stepping = clamp(stepping, u_raycast.min_stepping, u_raycast.max_stepping);
    stepping = mix(u_raycast.max_stepping, stepping, is_positive);

    return stepping;
}
