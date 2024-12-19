#include "./debug_voxel/debug_voxel_saturated"                  
#include "./debug_voxel/debug_voxel_coords"                  
#include "./debug_voxel/debug_voxel_texture_coords"          
#include "./debug_voxel/debug_voxel_gradient"                
#include "./debug_voxel/debug_voxel_gradient_length"         
#include "./debug_voxel/debug_voxel_value"                   

switch (u_debugging.option - debug.slot_voxel)
{ 
    case  1: fragColor = debug.voxel_saturated;       break;
    case  2: fragColor = debug.voxel_coords;          break;
    case  3: fragColor = debug.voxel_texture_coords;  break;
    case  4: fragColor = debug.voxel_gradient;        break;
    case  5: fragColor = debug.voxel_gradient_length; break;
    case  6: fragColor = debug.voxel_value;           break;
}