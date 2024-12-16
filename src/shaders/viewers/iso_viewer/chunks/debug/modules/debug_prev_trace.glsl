#include "./debug_prev_trace/debug_prev_trace_saturated"         
#include "./debug_prev_trace/debug_prev_trace_terminated"         
#include "./debug_prev_trace/debug_prev_trace_exhausted"          
#include "./debug_prev_trace/debug_prev_trace_distance"           
#include "./debug_prev_trace/debug_prev_trace_outside"            
#include "./debug_prev_trace/debug_prev_trace_position"            
#include "./debug_prev_trace/debug_prev_trace_derivative"         
#include "./debug_prev_trace/debug_prev_trace_step_distance"      
#include "./debug_prev_trace/debug_prev_trace_step_scaling"       
#include "./debug_prev_trace/debug_prev_trace_step_count"         
#include "./debug_prev_trace/debug_prev_trace_mean_step_scaling"  
#include "./debug_prev_trace/debug_prev_trace_mean_step_distance" 
#include "./debug_prev_trace/debug_prev_trace_stepped_distance"   
#include "./debug_prev_trace/debug_prev_trace_skipped_distance"   
#include "./debug_prev_trace/debug_prev_trace_spanned_distance" 

switch (u_debugging.option - debug.prev_trace_slot)
{ 
    case  1: fragColor = debug.prev_trace_saturated;           break;
    case  2: fragColor = debug.prev_trace_terminated;          break;
    case  3: fragColor = debug.prev_trace_exhausted;           break;
    case  4: fragColor = debug.prev_trace_outside;             break;
    case  5: fragColor = debug.prev_trace_distance;            break;
    case  6: fragColor = debug.prev_trace_position;            break;
    case  7: fragColor = debug.prev_trace_derivative;          break;
    case  8: fragColor = debug.prev_trace_step_distance;       break;
    case  9: fragColor = debug.prev_trace_step_scaling;        break;
    case 10: fragColor = debug.prev_trace_step_count;          break;
    case 11: fragColor = debug.prev_trace_mean_step_scaling;   break;
    case 12: fragColor = debug.prev_trace_mean_step_distance;  break;
    case 13: fragColor = debug.prev_trace_stepped_distance;    break;
    case 14: fragColor = debug.prev_trace_skipped_distance;    break;
    case 15: fragColor = debug.prev_trace_spanned_distance;    break;
}