/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float stepping_gradial
(
    in uniforms_raycast u_raycast,
    in uniforms_gradient u_gradient,
    in parameters_ray ray,
    in parameters_trace trace
)
{
    // Compute the alignment between the gradient and the ray direction.
    // This represents how much the ray is moving in the direction of the gradient.
    float gradial_alignment = max(dot(trace.gradient, ray.direction), 0.0);
    gradial_alignment = rampstep(u_gradient.min_length, u_gradient.max_length, gradial_alignment);

    // Interpolate the resolution based on the alignment.
    // when alignment is high, use higher resolution, when low, use lower resolution.
    float spacing = mix(u_raycast.max_stepping, u_raycast.min_stepping, gradial_alignment);

    return spacing;
}
