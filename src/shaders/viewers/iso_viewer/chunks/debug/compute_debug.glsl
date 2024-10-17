// COMPUTE_DEBUG

#include "./modules/debug"      

switch (u_debug.option)
{
    case  1: fragColor  = debug.trace_position;       break;
    case  2: fragColor  = debug.trace_coords;         break;
    case  3: fragColor  = debug.trace_distance;       break;
    case  4: fragColor  = debug.trace_depth;          break;
    case  5: fragColor  = debug.trace_traversed;      break;
    case  6: fragColor  = debug.trace_skipped;        break;
    case  7: fragColor  = debug.trace_steps;          break;
    case  8: fragColor  = debug.trace_error;          break;
    case  9: fragColor  = debug.trace_abs_error;      break;
    case 10: fragColor = debug.trace_value;          break;
    case 11: fragColor = debug.trace_color;          break;
    case 12: fragColor = debug.trace_shading;        break;
    case 13: fragColor = debug.trace_luminance;      break;
    case 14: fragColor = debug.trace_normal;         break;
    case 15: fragColor = debug.trace_gradient;       break;
    case 16: fragColor = debug.trace_gradient_norm;  break;
    case 17: fragColor = debug.trace_derivative;     break;
    case 18: fragColor = debug.trace_stepping;       break;
    case 19: fragColor = debug.trace_mean_stepping;  break;
    case 20: fragColor = debug.ray_direction;        break;
    case 21: fragColor = debug.ray_spacing;          break;
    case 22: fragColor = debug.ray_dithering;        break;
    case 23: fragColor = debug.ray_min_distance;     break;
    case 24: fragColor = debug.ray_max_distance;     break;
    case 25: fragColor = debug.ray_max_depth;        break;
    case 26: fragColor = debug.ray_max_steps;        break;
    case 27: fragColor = debug.frag_depth;           break;
    case 28: fragColor = debug.variable1;            break;
    case 29: fragColor = debug.variable2;            break;
    case 30: fragColor = debug.variable3;            break;
}
