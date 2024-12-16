#include "./debug_voxel/debug_voxel_coords"                  
#include "./debug_voxel/debug_voxel_step_coords"                  
#include "./debug_voxel/debug_voxel_texture_coords"          
#include "./debug_voxel/debug_voxel_gradient"                
#include "./debug_voxel/debug_voxel_gradient_length"         
#include "./debug_voxel/debug_voxel_value"                   
#include "./debug_voxel/debug_voxel_error"                   
#include "./debug_voxel/debug_voxel_abs_error"                   

switch (u_debugging.option - debug.voxel_slot)
{ 
    case 1: fragColor = debug.voxel_coords;          break;
    case 2: fragColor = debug.voxel_step_coords;     break;
    case 3: fragColor = debug.voxel_texture_coords;  break;
    case 4: fragColor = debug.voxel_gradient;        break;
    case 5: fragColor = debug.voxel_gradient_length; break;
    case 6: fragColor = debug.voxel_value;           break;
    case 7: fragColor = debug.voxel_error;           break;
    case 8: fragColor = debug.voxel_abs_error;       break;
}