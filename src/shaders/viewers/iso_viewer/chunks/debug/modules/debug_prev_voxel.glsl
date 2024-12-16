#include "./debug_prev_voxel/debug_prev_voxel_coords"                  
#include "./debug_prev_voxel/debug_prev_voxel_step_coords"                  
#include "./debug_prev_voxel/debug_prev_voxel_texture_coords"          
#include "./debug_prev_voxel/debug_prev_voxel_gradient"                
#include "./debug_prev_voxel/debug_prev_voxel_gradient_length"         
#include "./debug_prev_voxel/debug_prev_voxel_value"                   
#include "./debug_prev_voxel/debug_prev_voxel_error"                   
#include "./debug_prev_voxel/debug_prev_voxel_abs_error"                   

switch (u_debugging.option - debug.trace_slot)
{ 
    case 1: fragColor = debug.prev_voxel_coords;          break;
    case 2: fragColor = debug.prev_voxel_step_coords;     break;
    case 3: fragColor = debug.prev_voxel_texture_coords;  break;
    case 4: fragColor = debug.prev_voxel_gradient;        break;
    case 5: fragColor = debug.prev_voxel_gradient_length; break;
    case 6: fragColor = debug.prev_voxel_value;           break;
    case 7: fragColor = debug.prev_voxel_value;           break;
    case 8: fragColor = debug.prev_voxel_value;           break;
}