
// COMPUTE DEBUG

// position
vec4 debug_camera_position = to_color(map(box.min_position, box.max_position, camera.position));

// PRINT DEBUG

switch (u_debugging.option - debug_slot_camera)
{
    case 1: fragColor = debug_camera_position;      break;
}