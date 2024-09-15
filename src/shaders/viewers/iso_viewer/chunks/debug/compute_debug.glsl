// COMPUTE_DEBUG

#include "./modules/debug"      

switch (u_debug.option)
{
    case 1: gl_FragColor  = debug.trace_position;       break;
    case 2: gl_FragColor  = debug.trace_coords;         break;
    case 3: gl_FragColor  = debug.trace_distance;       break;
    case 4: gl_FragColor  = debug.trace_depth;          break;
    case 5: gl_FragColor  = debug.trace_traversed;      break;
    case 6: gl_FragColor  = debug.trace_skipped;        break;
    case 7: gl_FragColor  = debug.trace_steps;          break;
    case 8: gl_FragColor  = debug.trace_error;          break;
    case 9: gl_FragColor  = debug.trace_abs_error;      break;
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
    case 28: gl_FragColor = debug.variable1;            break;
    case 29: gl_FragColor = debug.variable2;            break;
    case 30: gl_FragColor = debug.variable3;            break;
}
