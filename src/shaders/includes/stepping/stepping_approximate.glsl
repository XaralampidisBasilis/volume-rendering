/**
 * Computes the resolution for raycasting based on the alignment of the gradient and ray direction.
 *
 * @param u_raycast - Uniforms for raycasting parameters including minimum and maximum resolution.
 * @param ray - Parameters of the ray including its direction.
 * @param gradient - Gradient vector at the current position in the volume.
 *
 * @return The computed resolution based on the gradient alignment.
 */
float stepping_approximate
(
    in uniforms_volume u_volume, 
    in uniforms_gradient u_gradient,
    in uniforms_raycast u_raycast,
    in float stepping_min,
    in float stepping_max,
    in vec3 ray_direction,
    in vec3 trace_normal,
    in float trace_steepness,
    in float value
)
{
    // get to model coordinates
    ray_direction = normalize(ray_direction * u_volume.size);
    vec3 gradient = - trace_normal * trace_steepness;

    float error = u_raycast.threshold - value;
    float derivative = dot(gradient, ray_direction);
    float factor = error / derivative;
    
    float stepping_factor = clamp(factor, stepping_min, stepping_max)
    stepping_factor = mix(stepping_max, stepping_factor, step(0.0, factor));

    return stepping_factor;
}
