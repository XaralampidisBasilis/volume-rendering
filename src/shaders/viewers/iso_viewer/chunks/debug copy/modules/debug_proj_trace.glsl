#include "./debug_proj_trace/debug_proj_trace_distance"           
#include "./debug_proj_trace/debug_proj_trace_outside"            
#include "./debug_proj_trace/debug_proj_trace_position"           
#include "./debug_proj_trace/debug_proj_trace_derivative"         
#include "./debug_proj_trace/debug_proj_trace_step_distance"      
#include "./debug_proj_trace/debug_proj_trace_step_count"         

switch (u_debugging.option - debug.proj_trace_slot)
{ 
    case 1: fragColor = debug.proj_trace_distance;      break;
    case 2: fragColor = debug.proj_trace_outside;       break;
    case 3: fragColor = debug.proj_trace_position;      break;
    case 4: fragColor = debug.proj_trace_derivative;    break;
    case 5: fragColor = debug.proj_trace_step_distance; break;
    case 6: fragColor = debug.proj_trace_step_count;    break;
}