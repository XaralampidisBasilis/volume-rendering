// COMPUTE_DEBUG

#include "./modules/debug"

switch (debugging.option)
{
    case  1: fragColor = debug.frag_depth;               break;
    case  2: fragColor = debug.ray_intersected;          break;
    case  3: fragColor = debug.ray_step_direction;       break;
    case  4: fragColor = debug.ray_step_distance;        break;
    case  5: fragColor = debug.ray_rand_distance;        break;
    case  6: fragColor = debug.ray_start_distance;       break;
    case  7: fragColor = debug.ray_end_distance;         break;
    case  8: fragColor = debug.ray_span_distance;        break;
    case  9: fragColor = debug.ray_start_position;       break;
    case 10: fragColor = debug.ray_end_position;         break;
    case 11: fragColor = debug.ray_box_start_distance;   break;
    case 12: fragColor = debug.ray_box_end_distance;     break;
    case 13: fragColor = debug.ray_box_span_distance;    break;
    case 14: fragColor = debug.ray_box_start_position;   break;
    case 15: fragColor = debug.ray_box_end_position;     break;
    case 16: fragColor = debug.ray_max_step_count;       break;
    case 17: fragColor = debug.ray_max_skip_count;       break;
    case 18: fragColor = debug.trace_sample_value;       break;
    case 19: fragColor = debug.trace_sample_error;       break;
    case 20: fragColor = debug.trace_sample_abs_error;   break;
    case 21: fragColor = debug.trace_normal;             break;
    case 22: fragColor = debug.trace_gradient;           break;
    case 23: fragColor = debug.trace_gradient_magnitude; break;
    case 24: fragColor = debug.trace_derivative_1st;     break;
    case 25: fragColor = debug.trace_derivative_2nd;     break;
    case 26: fragColor = debug.trace_derivative_3rd;     break;
    case 27: fragColor = debug.trace_outside;            break;
    case 28: fragColor = debug.trace_position;           break;
    case 29: fragColor = debug.trace_distance;           break;
    case 30: fragColor = debug.trace_distance_error;     break;
    case 31: fragColor = debug.trace_distance_diff;      break;
    case 32: fragColor = debug.trace_block_coords;       break;
    case 33: fragColor = debug.trace_voxel_coords;       break;
    case 34: fragColor = debug.trace_skip_distance;      break;
    case 35: fragColor = debug.trace_step_scaling;       break;
    case 36: fragColor = debug.trace_step_stretching;    break;
    case 37: fragColor = debug.trace_step_distance;      break;
    case 38: fragColor = debug.trace_mean_step_distance; break;
    case 39: fragColor = debug.trace_spanned_distance;   break;
    case 40: fragColor = debug.trace_stepped_distance;   break;
    case 41: fragColor = debug.trace_skipped_distance;   break;
    case 42: fragColor = debug.trace_step_count;         break;
    case 43: fragColor = debug.trace_skip_count;         break;
    case 44: fragColor = debug.trace_total_count;        break;
    case 45: fragColor = debug.trace_block_lod;          break;
    case 46: fragColor = debug.trace_block_occupancy;    break;
    case 47: fragColor = debug.trace_block_occupied;     break;
    case 48: fragColor = debug.trace_mapped_color;       break;
    case 49: fragColor = debug.trace_luminance;          break;
    case 50: fragColor = debug.trace_shaded_color;       break;
    case 51: fragColor = debug.variable1;                break;
    case 52: fragColor = debug.variable2;                break;
    case 53: fragColor = debug.variable3;                break;
}
