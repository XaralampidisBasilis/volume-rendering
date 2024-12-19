#include "./debug_frag/debug_frag_depth"               
#include "./debug_frag/debug_frag_position"            
#include "./debug_frag/debug_frag_normal_vector"       
#include "./debug_frag/debug_frag_view_vector"         
#include "./debug_frag/debug_frag_view_angle"         
#include "./debug_frag/debug_frag_camera_angle"       
#include "./debug_frag/debug_frag_mapped_value"        
#include "./debug_frag/debug_frag_mapped_color"     

switch (u_debugging.option - debug.slot_frag)
{
    case 1: fragColor = debug.frag_depth;         break;
    case 2: fragColor = debug.frag_position;      break;
    case 3: fragColor = debug.frag_normal_vector; break;
    case 4: fragColor = debug.frag_view_vector;   break;
    case 5: fragColor = debug.frag_view_angle;    break;
    case 6: fragColor = debug.frag_camera_angle;  break;
    case 7: fragColor = debug.frag_mapped_value;  break;
    case 8: fragColor = debug.frag_mapped_color;  break;
}