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
    // compute spacing based on linear approximation
    float error = u_raycast.threshold - trace.value;
    float alignment = dot(trace.gradient, ray.direction);
    float spacing = error / alignment;

    // compute the stepping factor
    float stepping = spacing / ray.spacing;
    stepping = mix(u_raycast.max_stepping, clamp(stepping, u_raycast.min_stepping, u_raycast.max_stepping), step(0.0, stepping));

    return stepping;
}
