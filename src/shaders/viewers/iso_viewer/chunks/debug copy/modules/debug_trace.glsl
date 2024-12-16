#include "./debug_trace/debug_trace_saturated"         
#include "./debug_trace/debug_trace_terminated"         
#include "./debug_trace/debug_trace_exhausted"          
#include "./debug_trace/debug_trace_distance"           
#include "./debug_trace/debug_trace_outside"            
#include "./debug_trace/debug_trace_position"            
#include "./debug_trace/debug_trace_derivative"         
#include "./debug_trace/debug_trace_step_distance"      
#include "./debug_trace/debug_trace_step_scaling"       
#include "./debug_trace/debug_trace_step_count"         
#include "./debug_trace/debug_trace_mean_step_scaling"  
#include "./debug_trace/debug_trace_mean_step_distance" 
#include "./debug_trace/debug_trace_stepped_distance"   
#include "./debug_trace/debug_trace_skipped_distance"   
#include "./debug_trace/debug_trace_spanned_distance" 

switch (u_debugging.option - debug.trace_slot)
{ 
    case  1: fragColor = debug.trace_saturated;           break;
    case  2: fragColor = debug.trace_terminated;          break;
    case  3: fragColor = debug.trace_exhausted;           break;
    case  4: fragColor = debug.trace_outside;             break;
    case  5: fragColor = debug.trace_distance;            break;
    case  6: fragColor = debug.trace_position;            break;
    case  7: fragColor = debug.trace_derivative;          break;
    case  8: fragColor = debug.trace_step_distance;       break;
    case  9: fragColor = debug.trace_step_scaling;        break;
    case 10: fragColor = debug.trace_step_count;          break;
    case 11: fragColor = debug.trace_mean_step_scaling;   break;
    case 12: fragColor = debug.trace_mean_step_distance;  break;
    case 13: fragColor = debug.trace_stepped_distance;    break;
    case 14: fragColor = debug.trace_skipped_distance;    break;
    case 15: fragColor = debug.trace_spanned_distance;    break;
}