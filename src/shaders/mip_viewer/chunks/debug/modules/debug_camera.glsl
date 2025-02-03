
// COMPUTE DEBUG

// direction
vec3 debug_camera_direction = camera.direction * 0.5 + 0.5;
debug.camera_direction = vec4(debug_camera_direction, 1.0);

// position
vec3 debug_camera_position = map(box.min_position, box.max_position, camera.position);
debug.camera_position = vec4(debug_camera_position, 1.0);

// near_distance
debug.camera_near_distance = vec4(vec3(camera.near_distance), 1.0);

// far_distance
debug.camera_far_distance = vec4(vec3(camera.far_distance), 1.0);
 

// PRINT DEBUG

switch (u_debugging.option - debug.slot_camera)
{
    case 1: fragColor = debug.camera_position;      break;
    case 2: fragColor = debug.camera_direction;     break;
    case 3: fragColor = debug.camera_far_distance;  break;
    case 4: fragColor = debug.camera_near_distance; break;
}