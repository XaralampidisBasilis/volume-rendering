vec4 debug_raycasting
(
    in uniforms_debug u_debug,
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    inout parameters_ray ray,
    inout parameters_trace trace
)
{
    switch (u_debug.option)
    {
        case 1: // position
            return vec4(vec3(trace.texel), 1.0);
        case 2: // normalized steps
            return vec4(vec3(trace.i_step) / vec3(ray.max_steps), 1.0);
        case 3: // steps
            return vec4(vec3(trace.i_step) / vec3(u_debug.max_iterations), 1.0);
        case 4: // value
            return vec4(vec3(trace.value), 1.0);
        case 5: // normal
            return vec4(trace.normal * 0.5 + 0.5, 1.0);
        case 6: // steepness
            return vec4(vec3(trace.steepness / u_gradient.max_length), 1.0);
        case 7: // gradient
            return vec4((trace.gradient / u_gradient.max_length) * 0.5 + 0.5, 1.0);
        case 8: // abs(gradient)
            return vec4(abs(trace.gradient / u_gradient.max_length), 1.0);
        case 9: // depth
            return vec4(vec3(trace.depth / length(2.0 * u_volume.size)), 1.0);
        case 10: // penetration
            return vec4(vec3((trace.depth - ray.bounds.x) / length(u_volume.size)), 1.0);
        default:
            return vec4(1.0, 0.0, 0.0, 1.0);
    }
}