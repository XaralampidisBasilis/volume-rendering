// COMPUTE_DEBUG

#include "./modules/debug"

switch (u_debugger.option)
{
    case  1: fragColor = debug.frag_depth;                   break;               
    case  2: fragColor = debug.ray_camera_position;          break;       
    case  3: fragColor = debug.ray_camera_direction;         break;       
    case  4: fragColor = debug.ray_step_direction;           break;       
    case  5: fragColor = debug.ray_step_distance;            break;             
    case  6: fragColor = debug.ray_rand_distance;            break;        
    case  7: fragColor = debug.ray_start_distance;           break;       
    case  8: fragColor = debug.ray_end_distance;             break;         
    case  9: fragColor = debug.ray_span_distance;            break;        
    case 10: fragColor = debug.ray_start_position;           break;       
    case 11: fragColor = debug.ray_end_position;             break;         
    case 12: fragColor = debug.ray_max_step_count;           break;       
    case 13: fragColor = debug.ray_min_start_distance;       break;       
    case 14: fragColor = debug.ray_max_end_distance;         break;       
    case 15: fragColor = debug.ray_max_span_distance;        break;       
    case 16: fragColor = debug.trace_terminated;             break;         
    case 17: fragColor = debug.trace_suspended;              break;          
    case 18: fragColor = debug.trace_distance;               break;   
    case 19: fragColor = debug.trace_position;               break;  
    case 20: fragColor = debug.trace_voxel_coords;           break;       
    case 21: fragColor = debug.trace_step_count;             break;         
    case 22: fragColor = debug.trace_step_distance;          break;      
    case 23: fragColor = debug.trace_step_scaling;           break;
    case 24: fragColor = debug.trace_mean_step_scaling;      break;  
    case 25: fragColor = debug.trace_mean_step_distance;     break;       
    case 26: fragColor = debug.max_trace_distance;           break;   
    case 27: fragColor = debug.max_trace_position;           break;  
    case 28: fragColor = debug.max_trace_voxel_coords;       break;       
    case 29: fragColor = debug.max_trace_step_count;         break;         
    case 30: fragColor = debug.max_trace_step_distance;      break;      
    case 31: fragColor = debug.max_trace_step_scaling;       break;      
    case 32: fragColor = debug.max_trace_sample_value;       break;  
    case 33: fragColor = debug.max_trace_mapped_color;       break; 
    case 34: fragColor = debug.max_trace_gradient;           break; 
    case 35: fragColor = debug.max_trace_gradient_magnitude; break; 
    case 36: fragColor = debug.max_trace_gradient_direction; break; 
    case 37: fragColor = debug.max_trace_derivative;         break;         
    case 38: fragColor = debug.variable1;                    break;         
    case 39: fragColor = debug.variable2;                    break;         
    case 40: fragColor = debug.variable3;                    break;         
}
 