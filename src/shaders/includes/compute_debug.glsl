vec4 compute_debug
(
    in uniforms_debug u_debug,
    in uniforms_gradient u_gradient, 
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_occupancy u_occupancy, 
    in parameters_ray ray,
    in parameters_trace trace,
    inout parameters_debug debug
)
{
    // https://www.hsluv.org
    const vec3 red = vec3(0.9372549019607843, 0.0, 0.0); 
    const vec3 blue = vec3(0.0, 0.43137254901960786, 1.0);
    
    vec2 b_bounds = bounds_box(ray.box_min, ray.box_max, ray.origin);
    float min_distance = b_bounds.x;
    float max_distance = b_bounds.y;
    float max_depth = max_distance - min_distance;

    debug.trace_position      = vec4(vec3(trace.texel), 1.0);
    debug.trace_coords        = vec4(vec3(trace.coords / (u_volume.dimensions - 1.0)), 1.0);
    debug.trace_distance      = vec4(vec3((trace.distance - min_distance) / max_depth), 1.0);
    debug.trace_depth         = vec4(vec3((trace.distance - ray.min_distance) / max_depth), 1.0);
    debug.trace_traversed     = vec4(vec3(trace.traversed / max_depth), 1.0);
    debug.trace_skipped       = vec4(vec3(trace.skipped / max_depth), 1.0);
    debug.trace_steps         = vec4(vec3(trace.steps) / vec3(u_raycast.max_steps), 1.0);
    debug.trace_error         = vec4(abs(trace.error / 0.01) * mix(blue, red, step(0.0, trace.error)), 1.0);
    debug.trace_abs_error     = vec4(abs(trace.error / 0.01) * red, 1.0);
    debug.trace_value         = vec4(vec3(trace.value), 1.0);
    debug.trace_color         = vec4(trace.color, 1.0);
    debug.trace_shading       = vec4(trace.shading, 1.0);
    debug.trace_luminance     = vec4(vec3(dot(trace.shading, vec3(0.2126, 0.7152, 0.0722))), 1.0);
    debug.trace_normal        = vec4(trace.normal * 0.5 + 0.5, 1.0);
    debug.trace_gradient      = vec4((trace.gradient / u_gradient.max_norm) * 0.5 + 0.5, 1.0);
    debug.trace_gradient_norm = vec4(vec3(trace.gradient_norm / u_gradient.max_norm), 1.0);
    debug.trace_derivative    = vec4(abs(trace.derivative  / u_gradient.max_norm) * mix(blue, red, step(0.0, trace.derivative)), 1.0);
    debug.trace_stepping      = vec4(vec3(map(u_raycast.min_stepping, u_raycast.max_stepping, trace.stepping)), 1.0);
    debug.trace_mean_stepping = vec4(vec3(map(u_raycast.min_stepping, u_raycast.max_stepping, trace.depth / ray.spacing / float(trace.steps))), 1.0);
    debug.ray_direction       = vec4(vec3(ray.direction * 0.5 + 0.5), 1.0);
    debug.ray_spacing         = vec4(vec3(ray.spacing / length(u_volume.spacing)), 1.0);
    debug.ray_dithering       = vec4(vec3(ray.dithering / (ray.spacing * u_raycast.max_stepping)), 1.0);
    debug.ray_min_distance    = vec4(vec3((ray.min_distance - min_distance) / max_depth), 1.0);
    debug.ray_max_distance    = vec4(vec3((ray.max_distance - min_distance) / max_depth), 1.0);
    debug.ray_max_depth       = vec4(vec3(ray.max_depth / max_depth), 1.0);
    debug.ray_max_steps       = vec4(vec3(ray.max_steps) / vec3(u_raycast.max_steps), 1.0);
    debug.frag_depth          = vec4(vec3(gl_FragDepth), 1.0);
    
    switch (u_debug.option)
    {
        case  1: return debug.trace_position;      
        case  2: return debug.trace_coords;      
        case  3: return debug.trace_distance;      
        case  4: return debug.trace_depth;         
        case  5: return debug.trace_traversed;     
        case  6: return debug.trace_skipped;       
        case  7: return debug.trace_steps;         
        case  8: return debug.trace_error;         
        case  9: return debug.trace_abs_error;     
        case 10: return debug.trace_value;         
        case 11: return debug.trace_color;         
        case 12: return debug.trace_shading;       
        case 13: return debug.trace_luminance;     
        case 14: return debug.trace_normal;        
        case 15: return debug.trace_gradient;      
        case 16: return debug.trace_gradient_norm; 
        case 17: return debug.trace_derivative;    
        case 18: return debug.trace_stepping;      
        case 19: return debug.trace_mean_stepping; 
        case 20: return debug.ray_direction;       
        case 21: return debug.ray_spacing;         
        case 22: return debug.ray_dithering;       
        case 23: return debug.ray_min_distance;    
        case 24: return debug.ray_max_distance;    
        case 25: return debug.ray_max_depth;       
        case 26: return debug.ray_max_steps;       
        case 27: return debug.frag_depth;          
        default: return gl_FragColor;
    }
}