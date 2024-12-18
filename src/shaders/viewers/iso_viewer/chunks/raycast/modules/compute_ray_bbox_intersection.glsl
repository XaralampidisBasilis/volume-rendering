
// Volume bounding box in model space
vec3 bbox_min_position = u_volume.min_position;
vec3 bbox_max_position = u_volume.max_position;

// shrink volume bounding box by a small amount to avoid numerical instabilities in the boundary
bbox_min_position += u_volume.spacing * MILLI_TOLERANCE;
bbox_max_position -= u_volume.spacing * MILLI_TOLERANCE;

// make sure volume bounding box is not bigger than volume box
bbox_min_position = max(bbox_min_position, box.min_position);
bbox_max_position = min(bbox_max_position, box.max_position);

// compute ray intersection distances with bounding box
vec2 ray_bbox_distances = intersect_box(bbox_min_position, bbox_max_position, camera.position, ray.step_direction);

// clamp bbox distances above zero for the case we are inside
ray_bbox_distances = max(ray_bbox_distances, 0.0);

// update ray if there is an intersection
if (ray_bbox_distances.x < ray_bbox_distances.y)
{
    ray.start_distance = ray_bbox_distances.x;
    ray.end_distance   = ray_bbox_distances.y;
    ray.span_distance  = ray_bbox_distances.y - ray_bbox_distances.x;
    ray.start_position = camera.position + ray.step_direction * ray_bbox_distances.x;
    ray.end_position   = camera.position + ray.step_direction * ray_bbox_distances.y;
}
// discard ray if no intersection
else
{
    #include "./discard_ray"
}
