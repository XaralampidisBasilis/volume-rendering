// volume box 
ray.box_min_position = vec3(0.0);
ray.box_max_position = u_volume.size;

// shrink volume box by a small amount to avoid numerical instabilities in the boundary
vec3 ray_min_position = ray.box_min_position + u_volume.spacing * MILLI_TOLERANCE;
vec3 ray_max_position = ray.box_max_position - u_volume.spacing * MILLI_TOLERANCE;

// compute current ray intersection distances with the volume box
vec2 ray_box_distances = intersect_box(ray_min_position, ray_max_position, ray.camera_position, ray.step_direction);

// clamp bbox distances above zero for the case we are inside
ray_box_distances = max(ray_box_distances, 0.0);

// updata ray if there is an intersection
if (ray_box_distances.x < ray_box_distances.y)
{
    // update ray box distances
    ray.box_start_distance = ray_box_distances.x;
    ray.box_end_distance   = ray_box_distances.y;
    ray.box_span_distance  = ray.box_end_distance - ray.box_start_distance;
    ray.box_start_position = ray.camera_position + ray.step_direction * ray.box_start_distance;
    ray.box_end_position   = ray.camera_position + ray.step_direction * ray.box_end_distance;

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
