
// compute current ray intersection distances with the volume box
vec2 entry_exit = intersect_box(box.min_position, box.max_position, camera.position, ray.inv_direction);

// set distances to zero when we are inside
entry_exit = max(entry_exit, 0.0); 

// update ray if there is an intersection 
if (entry_exit.x < entry_exit.y)
{
    // update ray box distances
    box.entry_distance = entry_exit.x;
    box.entry_position = entry_exit.x * ray.direction + camera.position;
    box.exit_distance  = entry_exit.y;
    box.exit_position  = entry_exit.y * ray.direction + camera.position;
    box.span_distance  = entry_exit.y - entry_exit.x;
    
    // update ray distances
    ray.start_distance = box.entry_distance;
    ray.start_position = box.entry_position;
    ray.end_distance   = box.exit_distance;
    ray.end_position   = box.exit_position;
    ray.span_distance  = box.span_distance;
}