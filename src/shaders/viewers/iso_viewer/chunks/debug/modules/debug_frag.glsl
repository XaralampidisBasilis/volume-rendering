#include "./debug_frag/frag_depth"              
#include "./debug_frag/frag_position"           
#include "./debug_frag/frag_normal_vector"      
#include "./debug_frag/frag_view_vector"        
#include "./debug_frag/frag_light_vector"       
#include "./debug_frag/frag_halfway_vector"     
#include "./debug_frag/frag_view_angle"         
#include "./debug_frag/frag_light_angle"        
#include "./debug_frag/frag_halfway_angle"      
#include "./debug_frag/frag_camera_angle"       
#include "./debug_frag/frag_mapped_value"       
#include "./debug_frag/frag_mapped_color"       
#include "./debug_frag/frag_ambient_color"      
#include "./debug_frag/frag_diffuse_color"      
#include "./debug_frag/frag_specular_color"     
#include "./debug_frag/frag_shaded_color"       
#include "./debug_frag/frag_shaded_luminance"   

switch (u_debugging.option - debug.frag_slot)
{
    case  1: fragColor = frag_depth;              break; 
    case  2: fragColor = frag_position;           break; 
    case  3: fragColor = frag_normal_vector;      break; 
    case  4: fragColor = frag_view_vector;        break; 
    case  5: fragColor = frag_light_vector;       break; 
    case  6: fragColor = frag_halfway_vector;     break; 
    case  7: fragColor = frag_view_angle;         break; 
    case  8: fragColor = frag_light_angle;        break; 
    case  9: fragColor = frag_halfway_angle;      break; 
    case 10: fragColor = frag_camera_angle;       break; 
    case 11: fragColor = frag_mapped_value;       break; 
    case 12: fragColor = frag_mapped_color;       break; 
    case 13: fragColor = frag_ambient_color;      break; 
    case 14: fragColor = frag_diffuse_color;      break; 
    case 15: fragColor = frag_specular_color;     break; 
    case 16: fragColor = frag_shaded_color;       break; 
    case 17: fragColor = frag_shaded_luminance;   break; 
}   