#include "./debug_box/debug_box_entry_distance"       
#include "./debug_box/debug_box_exit_distance"        
#include "./debug_box/debug_box_span_distance"        
#include "./debug_box/debug_box_entry_position"       
#include "./debug_box/debug_box_exit_position"        
#include "./debug_box/debug_box_min_entry_distance"   
#include "./debug_box/debug_box_max_exit_distance"    
#include "./debug_box/debug_box_max_span_distance"    

switch (u_debugging.option - debug.box_slot)
{
    case 1: fragColor = debug.box_entry_distance;     break;
    case 2: fragColor = debug.box_exit_distance;      break;
    case 3: fragColor = debug.box_span_distance;      break;
    case 4: fragColor = debug.box_entry_position;     break;
    case 5: fragColor = debug.box_exit_position;      break;
    case 6: fragColor = debug.box_min_entry_distance; break;
    case 7: fragColor = debug.box_max_exit_distance;  break;
    case 8: fragColor = debug.box_max_span_distance;  break;
}