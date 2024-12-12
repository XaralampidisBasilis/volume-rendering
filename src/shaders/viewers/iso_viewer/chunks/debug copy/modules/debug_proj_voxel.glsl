#include "./debug_proj_voxel/debug_proj_voxel_coords"             
#include "./debug_proj_voxel/debug_proj_voxel_texture_coords"     
#include "./debug_proj_voxel/debug_proj_voxel_gradient"           
#include "./debug_proj_voxel/debug_proj_voxel_gradient_length"           
#include "./debug_proj_voxel/debug_proj_voxel_value"     

switch (u_debugging.option - debug.proj_voxel_slot)
{ 
    case 1: fragColor = debug.proj_voxel_coords;          break;
    case 2: fragColor = debug.proj_voxel_texture_coords;  break;
    case 3: fragColor = debug.proj_voxel_gradient;        break;
    case 4: fragColor = debug.proj_voxel_gradient_length; break;
    case 5: fragColor = debug.proj_voxel_value;           break;
}