
#include "./debug_ray/debug_ray_discarded"            
#include "./debug_ray/debug_ray_step_direction"       
#include "./debug_ray/debug_ray_step_distance"        
#include "./debug_ray/debug_ray_rand_distance"        
#include "./debug_ray/debug_ray_start_distance"       
#include "./debug_ray/debug_ray_end_distance"         
#include "./debug_ray/debug_ray_span_distance"        
#include "./debug_ray/debug_ray_start_position"       
#include "./debug_ray/debug_ray_end_position"         
#include "./debug_ray/debug_ray_max_step_count"       
#include "./debug_ray/debug_ray_max_skip_count"       
#include "./debug_ray/debug_ray_min_value"       
#include "./debug_ray/debug_ray_max_value"   
#include "./debug_ray/debug_ray_range_value"   

switch (u_debugging.option - debug.slot_ray)
{
    case  1: fragColor = debug.ray_discarded;      break;
    case  2: fragColor = debug.ray_step_direction; break;
    case  3: fragColor = debug.ray_step_distance;  break;
    case  4: fragColor = debug.ray_rand_distance;  break;
    case  5: fragColor = debug.ray_start_distance; break;
    case  6: fragColor = debug.ray_end_distance;   break;
    case  7: fragColor = debug.ray_span_distance;  break;
    case  8: fragColor = debug.ray_start_position; break;
    case  9: fragColor = debug.ray_end_position;   break;
    case 10: fragColor = debug.ray_max_step_count; break;
    case 11: fragColor = debug.ray_max_skip_count; break;
    case 12: fragColor = debug.ray_min_value;      break;
    case 13: fragColor = debug.ray_max_value;      break;
    case 14: fragColor = debug.ray_range_value;     break;
}