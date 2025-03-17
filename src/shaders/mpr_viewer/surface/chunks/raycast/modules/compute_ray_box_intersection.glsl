// compute box min/max coords
box.min_coords = ivec3(0);
box.max_coords = ivec3(u_volume.dimensions) - 1;

// compute box min/max positions
box.min_position = vec3(box.min_coords + 0);
box.max_position = vec3(box.max_coords + 1);
box.min_position += TOLERANCE.CENTI;
box.max_position -= TOLERANCE.CENTI; 

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
    box.entry_position = ray_box_distances.x * ray.direction + camera.position;
    box.exit_distance  = ray_box_distances.y;
    box.exit_position  = ray_box_distances.y * ray.direction + camera.position;
    box.span_distance  = ray_box_distances.y - ray_box_distances.x;
    
    // update ray distances
    ray.start_distance = box.entry_distance;
    ray.start_position = box.entry_position;
    ray.end_distance   = box.exit_distance;
    ray.end_position   = box.exit_position;
    ray.span_distance  = box.span_distance;
}
else
{
    #include "./discard_ray"
}
