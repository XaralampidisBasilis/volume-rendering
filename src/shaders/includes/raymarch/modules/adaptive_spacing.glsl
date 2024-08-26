/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float adaptive_spacing
(
    in uniforms_volume u_volume, 
    in float spacing_min,
    in float spacing_max,
    in vec3 ray_direction,
    in vec3 trace_normal,
    in float trace_steepness
)
{
    // get to model coordinates
    ray_direction = normalize(ray_direction * u_volume.size);
    trace_normal = normalize(trace_normal / u_volume.spacing);

    // Compute the alignment between the gradient and the ray direction.
    // This represents how much the ray is moving in the direction of the gradient.
    float alignment = max(dot(trace_normal, ray_direction), 0.0) * trace_steepness;
    // float alignment = max(dot(trace_normal, ray_direction), 0.0);
    // float alignment = trace_steepness;

    // Interpolate the resolution based on the alignment.
    // when alignment is high, use higher resolution, when low, use lower resolution.
    float spacing = mix(spacing_max, spacing_min, alignment);

    return spacing;
}
