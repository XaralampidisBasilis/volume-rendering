
// COMPUTE DEBUG

// direction
vec4 debug_camera_direction = to_color(camera.direction * 0.5 + 0.5);

// position
vec4 debug_camera_position = to_color(map(box.min_position, box.max_position, camera.position));

// near_distance
vec4 debug_camera_near_distance = to_color(camera.near_distance);

// far_distance
vec4 debug_camera_far_distance = to_color(camera.far_distance);
 

// PRINT DEBUG

switch (u_debugging.option - debug.slot_camera)
{
    case 1: fragColor = debug_camera_position;      break;
    case 2: fragColor = debug_camera_direction;     break;
    case 3: fragColor = debug_camera_far_distance;  break;
    case 4: fragColor = debug_camera_near_distance; break;
}