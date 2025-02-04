
// COMPUTE DEBUG 

// entry distance
vec4 debug_box_entry_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, box.entry_distance));

// exit distance
vec4 debug_box_exit_distance = to_color(map(box.min_entry_distance, box.max_exit_distance, box.exit_distance));

// span distance
vec4 debug_box_span_distance = to_color(map(0.0, box.max_span_distance, box.span_distance));

// entry position
vec4 debug_box_entry_position = to_color(map(box.min_position, box.max_position, box.entry_position));

// exit position
vec4 debug_box_exit_position = to_color(map(box.min_position, box.max_position, box.exit_position));

// min entry distance
vec4 debug_box_min_entry_distance = to_color(map(camera.near_distance, camera.far_distance, box.min_entry_distance));

// max exit distance
vec4 debug_box_max_exit_distance = to_color(map(camera.near_distance, camera.far_distance, box.max_exit_distance));

// max span distance
vec4 debug_box_max_span_distance = to_color(map(0.0, camera.far_distance - camera.near_distance, box.max_span_distance));


// PRINT DEBUG

switch (u_debugging.option - debug.slot_box)
{
    case 1: fragColor = debug_box_entry_distance;     break;
    case 2: fragColor = debug_box_exit_distance;      break;
    case 3: fragColor = debug_box_span_distance;      break;
    case 4: fragColor = debug_box_entry_position;     break;
    case 5: fragColor = debug_box_exit_position;      break;
    case 6: fragColor = debug_box_min_entry_distance; break;
    case 7: fragColor = debug_box_max_exit_distance;  break;
    case 8: fragColor = debug_box_max_span_distance;  break;
}