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
    const vec3 red = vec3(0.9372549019607843, 0.0, 0.0); // https://www.hsluv.org
    const vec3 blue = vec3(0.0, 0.43137254901960786, 1.0);

    switch (u_debug.option)
    {
        // trace_position
        case 1: 
            return vec4(vec3(trace.texel), 1.0);

        // trace_steps
        case 2: 
            return vec4(vec3(trace.steps) / vec3(u_raycast.max_steps), 1.0);

        // trace_value
        case 3:
            return vec4(vec3(trace.value), 1.0);

        // trace_error
        case 4:
            return vec4(abs(trace.error / 0.01) * mix(blue, red, step(0.0, trace.error)), 1.0);
                        
        // trace_abs_error
        case 5:
            return vec4(abs(trace.error / 0.01) * red, 1.0);
                        
        // trace_gradient_norm
        case 6: 
            return vec4(vec3(trace.gradient_norm / u_gradient.max_norm), 1.0);

        // trace_derivative
        case 7: 
            return vec4(vec3(trace.derivative / u_gradient.max_norm), 1.0);

        // trace_normal
        case 8: 
            return vec4(trace.normal * 0.5 + 0.5, 1.0);

        // trace_gradient
        case 9: 
            return vec4((trace.gradient / u_gradient.max_norm) * 0.5 + 0.5, 1.0);

        // trace_distance
        case 10: 
            return vec4(vec3((trace.distance - box_bounds.x) / length(u_volume.size)), 1.0);

        // trace_depth
        case 11: 
            return vec4(vec3((trace.distance - ray.min_distance) / length(u_volume.size)), 1.0);

        // trace_color
        case 12: 
            return vec4(trace.color, 1.0);
        
        // trace_shading
        case 13: 
            return vec4(trace.shading, 1.0);

        // trace_luminance
        case 14: 
            return vec4(vec3(dot(trace.shading, vec3(0.2126, 0.7152, 0.0722))), 1.0);

        // ray_dithering
        case 15: 
            return vec4(vec3(ray.dithering / (ray.spacing * u_raycast.max_stepping)), 1.0);

        // ray_min_distance
        case 16: 
            return  vec4(vec3((ray.min_distance - box_bounds.x) / length(u_volume.size)), 1.0);

        // ray_max_distance
        case 17: 
            return  vec4(vec3((ray.max_distance - box_bounds.x) / length(u_volume.size)), 1.0);

        // ray_max_depth
        case 18: 
            return vec4(vec3(ray.max_depth / length(u_volume.size)), 1.0);
            
        // ray_spacing
        case 19: 
            return vec4(vec3(ray.spacing / length(u_volume.spacing)), 1.0); 

        // ray_direction
        case 20: 
            return vec4(vec3(ray.direction * 0.5 + 0.5), 1.0);

        // frag_depth
        case 21: 
            return vec4(vec3(gl_FragDepth), 1.0);

        // default
        default:
            return gl_FragColor;
    }
}