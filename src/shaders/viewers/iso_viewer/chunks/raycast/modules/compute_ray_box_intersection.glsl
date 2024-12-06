// volume box 
box.min_position = vec3(0.0);
box.max_position = u_volume.size;

// shrink volume box by a small amount to avoid numerical instabilities in the boundary
box.min_position += u_volume.spacing * MILLI_TOLERANCE;
box.max_position -= u_volume.spacing * MILLI_TOLERANCE;

// compute current ray intersection distances with the volume box
vec2 ray_box_distances = intersect_box(box.min_position, box.max_position, camera.position, ray.step_direction);

// clamp bbox distances above zero for the case we are inside
ray_box_distances = max(ray_box_distances, 0.0);

// update ray if there is an intersection 
if (ray_box_distances.x < ray_box_distances.y)
{
    // update ray box distances
    box.entry_distance = ray_box_distances.x;
    box.exit_distance  = ray_box_distances.y;
    box.span_distance  = ray_box_distances.y - ray_box_distances.x;
    box.entry_position = camera.position + ray.step_direction * ray_box_distances.x;
    box.exit_position  = camera.position + ray.step_direction * ray_box_distances.y;

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
