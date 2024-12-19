#include "./debug_camera/debug_camera_position"          
#include "./debug_camera/debug_camera_direction"         
#include "./debug_camera/debug_camera_far_distance"      
#include "./debug_camera/debug_camera_near_distance"  

switch (u_debugging.option - debug.slot_camera)
{
    case 1: fragColor = debug.camera_position;      break;
    case 2: fragColor = debug.camera_direction;     break;
    case 3: fragColor = debug.camera_far_distance;  break;
    case 4: fragColor = debug.camera_near_distance; break;
}