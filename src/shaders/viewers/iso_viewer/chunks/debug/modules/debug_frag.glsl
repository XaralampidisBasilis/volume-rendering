#include "./debug_frag/debug_frag_depth"              
#include "./debug_frag/debug_frag_position"           
#include "./debug_frag/debug_frag_normal_vector"      
#include "./debug_frag/debug_frag_view_vector"        
#include "./debug_frag/debug_frag_light_vector"       
#include "./debug_frag/debug_frag_halfway_vector"     
#include "./debug_frag/debug_frag_view_angle"         
#include "./debug_frag/debug_frag_light_angle"        
#include "./debug_frag/debug_frag_halfway_angle"      
#include "./debug_frag/debug_frag_camera_angle"       
#include "./debug_frag/debug_frag_mapped_value"       
#include "./debug_frag/debug_frag_mapped_color"       
#include "./debug_frag/debug_frag_ambient_color"      
#include "./debug_frag/debug_frag_diffuse_color"      
#include "./debug_frag/debug_frag_specular_color"     
#include "./debug_frag/debug_frag_shaded_color"       
#include "./debug_frag/debug_frag_shaded_luminance"   

switch (u_debugging.option - debug.slot_frag)
{
    case  1: fragColor = debug.frag_depth;              break; 
    case  2: fragColor = debug.frag_position;           break; 
    case  3: fragColor = debug.frag_normal_vector;      break; 
    case  4: fragColor = debug.frag_view_vector;        break; 
    case  5: fragColor = debug.frag_light_vector;       break; 
    case  6: fragColor = debug.frag_halfway_vector;     break; 
    case  7: fragColor = debug.frag_view_angle;         break; 
    case  8: fragColor = debug.frag_light_angle;        break; 
    case  9: fragColor = debug.frag_halfway_angle;      break; 
    case 10: fragColor = debug.frag_camera_angle;       break; 
    case 11: fragColor = debug.frag_mapped_value;       break; 
    case 12: fragColor = debug.frag_mapped_color;       break; 
    case 13: fragColor = debug.frag_ambient_color;      break; 
    case 14: fragColor = debug.frag_diffuse_color;      break; 
    case 15: fragColor = debug.frag_specular_color;     break; 
    case 16: fragColor = debug.frag_shaded_color;       break; 
    case 17: fragColor = debug.frag_shaded_luminance;   break; 
}   