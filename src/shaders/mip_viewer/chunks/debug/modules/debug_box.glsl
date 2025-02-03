
// COMPUTE DEBUG 

// entry distance
float debug_box_entry_distance = map(box.min_entry_distance, box.max_exit_distance, box.entry_distance);
debug.box_entry_distance = vec4(vec3(debug_box_entry_distance), 1.0);

// exit distance
float debug_box_exit_distance = map(box.min_entry_distance, box.max_exit_distance, box.exit_distance);
debug.box_exit_distance = vec4(vec3(debug_box_exit_distance), 1.0);

// span distance
float debug_box_span_distance = map(0.0, box.max_span_distance, box.span_distance);
debug.box_span_distance = vec4(vec3(debug_box_span_distance), 1.0);

// entry position
vec3 debug_box_entry_position = map(box.min_position, box.max_position, box.entry_position);
debug.box_entry_position = vec4(debug_box_entry_position, 1.0);

// exit position
vec3 debug_box_exit_position = map(box.min_position, box.max_position, box.exit_position);
debug.box_exit_position = vec4(debug_box_exit_position, 1.0);

// min entry distance
float debug_box_min_entry_distance = map(camera.near_distance, camera.far_distance, box.min_entry_distance);;
debug.box_min_entry_distance = vec4(vec3(box.min_entry_distance), 1.0);

// max exit distance
float debug_box_max_exit_distance = map(camera.near_distance, camera.far_distance, box.max_exit_distance);
debug.box_max_exit_distance = vec4(vec3(box.max_exit_distance), 1.0);

// max span distance
float debug_box_max_span_distance = map(0.0, camera.far_distance - camera.near_distance, box.max_span_distance);
debug.box_max_span_distance = vec4(vec3(box.max_span_distance), 1.0);


// PRINT DEBUG

switch (u_debugging.option - debug.slot_box)
{
    case 1: fragColor = debug.box_entry_distance;     break;
    case 2: fragColor = debug.box_exit_distance;      break;
    case 3: fragColor = debug.box_span_distance;      break;
    case 4: fragColor = debug.box_entry_position;     break;
    case 5: fragColor = debug.box_exit_position;      break;
    case 6: fragColor = debug.box_min_entry_distance; break;
    case 7: fragColor = debug.box_max_exit_distance;  break;
    case 8: fragColor = debug.box_max_span_distance;  break;
}