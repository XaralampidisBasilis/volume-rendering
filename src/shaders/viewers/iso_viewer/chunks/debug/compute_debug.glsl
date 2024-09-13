
// https://www.hsluv.org
const vec3 red = vec3(0.9372549019607843, 0.0, 0.0); 
const vec3 blue = vec3(0.0, 0.43137254901960786, 1.0);

vec2 b_bounds = bounds_box(ray.box_min, ray.box_max, ray.origin);
float min_distance = b_bounds.x;
float max_distance = b_bounds.y;
float max_depth = max_distance - min_distance;

debug.trace_position      = vec4(vec3(trace.texel), 1.0);
debug.trace_coords        = vec4(vec3(trace.coords * u_volume.inv_dimensions), 1.0);
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
    case  1: gl_FragColor = debug.trace_position;       break;        
    case  2: gl_FragColor = debug.trace_coords;         break;        
    case  3: gl_FragColor = debug.trace_distance;       break;        
    case  4: gl_FragColor = debug.trace_depth;          break;           
    case  5: gl_FragColor = debug.trace_traversed;      break;       
    case  6: gl_FragColor = debug.trace_skipped;        break;         
    case  7: gl_FragColor = debug.trace_steps;          break;           
    case  8: gl_FragColor = debug.trace_error;          break;           
    case  9: gl_FragColor = debug.trace_abs_error;      break;       
    case 10: gl_FragColor = debug.trace_value;          break;           
    case 11: gl_FragColor = debug.trace_color;          break;           
    case 12: gl_FragColor = debug.trace_shading;        break;         
    case 13: gl_FragColor = debug.trace_luminance;      break;       
    case 14: gl_FragColor = debug.trace_normal;         break;          
    case 15: gl_FragColor = debug.trace_gradient;       break;        
    case 16: gl_FragColor = debug.trace_gradient_norm;  break;   
    case 17: gl_FragColor = debug.trace_derivative;     break;      
    case 18: gl_FragColor = debug.trace_stepping;       break;        
    case 19: gl_FragColor = debug.trace_mean_stepping;  break;   
    case 20: gl_FragColor = debug.ray_direction;        break;         
    case 21: gl_FragColor = debug.ray_spacing;          break;           
    case 22: gl_FragColor = debug.ray_dithering;        break;         
    case 23: gl_FragColor = debug.ray_min_distance;     break;      
    case 24: gl_FragColor = debug.ray_max_distance;     break;      
    case 25: gl_FragColor = debug.ray_max_depth;        break;         
    case 26: gl_FragColor = debug.ray_max_steps;        break;         
    case 27: gl_FragColor = debug.frag_depth;           break;      
}
