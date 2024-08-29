/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float stepping_directional
(
    in uniforms_volume u_volume, 
    in float min_stepping,
    in float max_stepping,
    in vec3 ray_direction,
    in vec3 trace_normal,
)
{
    // get to model coordinates
    ray_direction = normalize(ray_direction * u_volume.size);

    // Compute the alignment between the gradient and the ray direction.
    // This represents how much the ray is moving in the direction of the gradient.
    float alignment = max(dot(-trace_normal, ray_direction), 0.0);

    // Interpolate the resolution based on the alignment.
    // when alignment is high, use higher resolution, when low, use lower resolution.
    float spacing = mix(max_stepping, min_stepping, alignment);

    return spacing;
}
