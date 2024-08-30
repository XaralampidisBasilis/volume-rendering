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
    in float stepping_min,
    in float stepping_max,
    in vec3 ray_direction,
    in vec3 trace_normal,
    in float trace_steepness
)
{
    // Compute the alignment between the gradient and the ray direction.
    // This represents how much the ray is moving in the direction of the gradient.
    float alignment = max(dot(-trace_normal, ray_direction), 0.0) * trace_steepness;

    // Interpolate the resolution based on the alignment.
    // when alignment is high, use higher resolution, when low, use lower resolution.
    float stepping = mix(stepping_max, stepping_min, alignment);

    return stepping;
}
