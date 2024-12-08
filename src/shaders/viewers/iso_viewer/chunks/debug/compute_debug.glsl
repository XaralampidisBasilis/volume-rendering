// COMPUTE_DEBUG

#include "./modules/debug"

switch (u_debugging.option)
{
    case  1: fragColor = debug.box_entry_distance;       break;
    case  2: fragColor = debug.box_exit_distance;        break;
    case  3: fragColor = debug.box_span_distance;        break;
    case  4: fragColor = debug.box_entry_position;       break;
    case  5: fragColor = debug.box_exit_position;        break;
    case  6: fragColor = debug.box_min_entry_distance;   break;
    case  7: fragColor = debug.box_max_exit_distance;    break;
    case  8: fragColor = debug.box_max_span_distance;    break;
    case  9: fragColor = debug.camera_position;          break;
    case 10: fragColor = debug.camera_direction;         break;
    case 11: fragColor = debug.camera_far_distance;      break;
    case 12: fragColor = debug.camera_near_distance;     break;
    case 13: fragColor = debug.frag_depth;               break;
    case 14: fragColor = debug.frag_position;            break;
    case 15: fragColor = debug.frag_normal_vector;       break;
    case 16: fragColor = debug.frag_view_vector;         break;
    case 17: fragColor = debug.frag_light_vector;        break;
    case 18: fragColor = debug.frag_halfway_vector;      break;
    case 19: fragColor = debug.frag_mapped_value;        break;
    case 20: fragColor = debug.frag_mapped_color;        break;
    case 21: fragColor = debug.frag_shaded_color;        break;
    case 22: fragColor = debug.frag_shaded_luminance;    break;
    case 23: fragColor = debug.ray_discarded;            break;
    case 24: fragColor = debug.ray_step_direction;       break;
    case 25: fragColor = debug.ray_step_distance;        break;
    case 26: fragColor = debug.ray_rand_distance;        break;
    case 27: fragColor = debug.ray_start_distance;       break;
    case 28: fragColor = debug.ray_end_distance;         break;
    case 29: fragColor = debug.ray_span_distance;        break;
    case 30: fragColor = debug.ray_start_position;       break;
    case 31: fragColor = debug.ray_end_position;         break;
    case 32: fragColor = debug.ray_max_step_count;       break;
    case 33: fragColor = debug.ray_max_skip_count;       break;
    case 34: fragColor = debug.trace_intersected;        break;
    case 35: fragColor = debug.trace_terminated;         break;
    case 36: fragColor = debug.trace_exhausted;          break;
    case 37: fragColor = debug.trace_distance;           break;
    case 38: fragColor = debug.trace_outside;            break;
    case 39: fragColor = debug.trace_position;           break;
    case 40: fragColor = debug.trace_error;              break;
    case 41: fragColor = debug.trace_abs_error;          break;
    case 42: fragColor = debug.trace_derivative;         break;
    case 43: fragColor = debug.trace_delta_distance;     break;
    case 44: fragColor = debug.trace_step_distance;      break;
    case 45: fragColor = debug.trace_step_scaling;       break;
    case 46: fragColor = debug.trace_step_stretching;    break;
    case 47: fragColor = debug.trace_step_count;         break;
    case 48: fragColor = debug.trace_mean_step_scaling;  break;
    case 49: fragColor = debug.trace_mean_step_distance; break;
    case 50: fragColor = debug.trace_stepped_distance;   break;
    case 51: fragColor = debug.trace_skipped_distance;   break;
    case 52: fragColor = debug.trace_spanned_distance;   break;
    case 53: fragColor = debug.voxel_coords;             break;
    case 54: fragColor = debug.voxel_texture_coords;     break;
    case 55: fragColor = debug.voxel_gradient;           break;
    case 56: fragColor = debug.voxel_gradient_length;    break;
    case 57: fragColor = debug.voxel_value;              break;
    case 58: fragColor = debug.block_value;              break;
    case 59: fragColor = debug.block_occupied;           break;
    case 60: fragColor = debug.block_coords;             break;
    case 61: fragColor = debug.block_skip_count;         break;
    case 62: fragColor = debug.variable1;                break;
    case 63: fragColor = debug.variable2;                break;
    case 64: fragColor = debug.variable3;                break;
}
