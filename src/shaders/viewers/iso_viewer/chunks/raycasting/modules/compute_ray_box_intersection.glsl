
// compute current ray intersection distances with the volume box
vec2 ray_box_distances = intersect_box(ray.min_position, ray.max_position, ray.origin_position, ray.step_direction);

// clamp bbox distances above zero for the case we are inside
ray_box_distances = max(ray_box_distances, 0.0);

// updata ray if there is an intersection
if (ray_box_distances.x < ray_box_distances.y)
{
    // update ray box distances
    ray.box_start_distance = ray_box_distances.x;
    ray.box_end_distance   = ray_box_distances.y;
    ray.box_span_distance  = ray.box_end_distance - ray.box_start_distance;
    ray.box_start_position = ray.origin_position + ray.step_direction * ray.box_start_distance;
    ray.box_end_position   = ray.origin_position + ray.step_direction * ray.box_end_distance;

    // update ray distances
    ray.start_distance = ray.box_start_distance;
    ray.end_distance   = ray.box_end_distance;
    ray.span_distance  = ray.box_span_distance;
    ray.start_position = ray.box_start_position;
    ray.end_position   = ray.box_end_position;
}
else
{
    #include "./discard_ray"
}
