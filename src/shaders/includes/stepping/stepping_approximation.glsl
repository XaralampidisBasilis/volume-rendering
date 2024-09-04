/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float stepping_approximation
(
    in uniforms_raycast u_raycast,
    in parameters_ray ray,
    in parameters_trace trace
)
{
    // compute spacing based on linear approximation
    float value_error = u_raycast.threshold - trace.value;
    float gradial_alignment = dot(trace.gradient, ray.direction);
    float spacing = value_error / gradial_alignment;

    // compute the stepping factor
    float stepping = spacing / ray.spacing;
    stepping = clamp(stepping, u_raycast.min_stepping, u_raycast.max_stepping);
    stepping = (stepping <= 0.0) ? u_raycast.max_stepping : stepping;
    // stepping = mix(u_raycast.stepping_max, stepping, step(0.0, stepping));

    return stepping;
}
