#include "./utils/sdf_box"

vec4 compute_debug
(
    in uniforms_debug u_debug,
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in parameters_ray ray,
    in parameters_trace trace
)
{
    vec2 box_bounds = sdf_box(ray.origin, u_occupancy.box_min, u_occupancy.box_max);

    switch (u_debug.option)
    {
        // trace_position
        case 1: 
            return vec4(vec3(trace.texel), 1.0);

        // trace_steps
        case 2: 
            return vec4(vec3(trace.i_step) / vec3(u_raycast.max_steps), 1.0);

        // trace_value
        case 3:
            return vec4(vec3(trace.value), 1.0);

        // trace_error
        case 4:
            return vec4(abs(trace.error / 0.01) * mix(
                        vec3(0.0, 0.43137254901960786, 1.0), // https://www.hsluv.org/
                        vec3(0.9372549019607843, 0.0, 0.0), // https://www.hsluv.org/
                        step(0.0, trace.error)), 1.0);
                        
        // trace_steepness
        case 5: 
            return vec4(vec3(trace.steepness / u_gradient.max_length), 1.0);

        // trace_normal
        case 6: 
            return vec4(trace.normal * 0.5 + 0.5, 1.0);

        // trace_gradient
        case 7: 
            return vec4((trace.gradient / u_gradient.max_length) * 0.5 + 0.5, 1.0);

        // trace_depth
        case 8: 
            return vec4(vec3((trace.depth - box_bounds.x) / length(u_volume.size)), 1.0);

        // trace_penetration
        case 9: 
            return vec4(vec3((trace.depth - ray.bounds.x) / length(u_volume.size)), 1.0);

        // trace_color
        case 10: 
            return vec4(trace.color, 1.0);

        // trace_luminance
        case 11: 
            return vec4(vec3(dot(trace.lighting, vec3(0.2126, 0.7152, 0.0722))), 1.0);

        // ray_dithering
        case 12: 
            return vec4(vec3(ray.dithering / (ray.spacing * u_raycast.max_stepping)), 1.0);

        // ray_min_bound
        case 13: 
            return  vec4(vec3((ray.bounds.x - box_bounds.x) / length(u_volume.size)), 1.0);

        // ray_max_bound
        case 14: 
            return  vec4(vec3((ray.bounds.y - box_bounds.x) / length(u_volume.size)), 1.0);

        // ray_span
        case 15: 
            return vec4(vec3(ray.span / length(u_volume.size)), 1.0);
            
        // ray_spacing
        case 16: 
            return vec4(vec3(ray.spacing / length(u_volume.spacing)), 1.0); 

        // ray_direction
        case 17: 
            return vec4(vec3(ray.direction * 0.5 + 0.5), 1.0);

        // frag_depth
        case 18: 
            return vec4(vec3(gl_FragDepth), 1.0);

        // default
        default:
            return gl_FragColor;
    }
}