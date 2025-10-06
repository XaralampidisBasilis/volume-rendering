
// compute current ray intersection distances with the volume box
vec2 bbox_entry_exit = intersect_box(u_bbox.min_position, u_bbox.max_position, camera.position, ray.inv_direction);

// set distances to zero when we are inside
bbox_entry_exit = max(bbox_entry_exit, 0.0); 

// update ray if there is an intersection 
if (bbox_entry_exit.x < bbox_entry_exit.y)
{
    // update ray box distances
    ray.start_distance = bbox_entry_exit.x;
    ray.start_position = bbox_entry_exit.x * ray.direction + camera.position;
    ray.end_distance   = bbox_entry_exit.y;
    ray.end_position   = bbox_entry_exit.y * ray.direction + camera.position;
    ray.span_distance  = bbox_entry_exit.y - bbox_entry_exit.x;
}