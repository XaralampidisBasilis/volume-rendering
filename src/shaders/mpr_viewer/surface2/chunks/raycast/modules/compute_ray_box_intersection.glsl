
// smaller volume box to avoid boundary instabilities
box.min_position = vec3(0.0) + u_volume.inv_dimensions * TOLERANCE.CENTI;
box.max_position = vec3(1.0) - u_volume.inv_dimensions * TOLERANCE.CENTI;

// compute rays bound distances with the volume box
vec2 ray_box_bounds = box_bounds(box.min_position, box.max_position, camera.position);
box.min_entry_distance = ray_box_bounds.x;
box.max_exit_distance  = ray_box_bounds.y;
box.max_span_distance  = ray_box_bounds.y - ray_box_bounds.x;

// compute current ray intersection distances with the volume box
vec2 ray_box_distances = intersect_box(box.min_position, box.max_position, camera.position, ray.direction);
ray_box_distances = max(ray_box_distances, 0.0); // clamp bbox distances above zero for the case we are inside

// update ray if there is an intersection 
if (ray_box_distances.x < ray_box_distances.y)
{
    // update ray box distances
    box.entry_distance = ray_box_distances.x;
    box.exit_distance  = ray_box_distances.y;
    box.span_distance  = ray_box_distances.y - ray_box_distances.x;
    box.entry_position = camera.position + ray.direction * ray_box_distances.x;
    box.exit_position  = camera.position + ray.direction * ray_box_distances.y;
    
    // update ray distances
    ray.start_distance = box.entry_distance;
    ray.end_distance   = box.exit_distance;
    ray.span_distance  = box.span_distance;
    ray.start_position = box.entry_position;
    ray.end_position   = box.exit_position;
}
// discard ray if there is no intersection
else
{
    #include "./discard_ray"
}
