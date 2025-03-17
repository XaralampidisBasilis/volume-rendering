
// Volume bounding box in model space
vec3 bbox_min_position = vec3(u_bbox.min_coords + 0);
vec3 bbox_max_position = vec3(u_bbox.max_coords + 1);
bbox_min_position += TOLERANCE.CENTI;
bbox_max_position -= TOLERANCE.CENTI;

// make sure volume bounding box is not bigger than volume box
bbox_min_position = max(box.min_position, bbox_min_position);
bbox_max_position = min(box.max_position, bbox_max_position);

// compute ray intersection distances with bounding box
vec2 ray_bbox_distances = intersect_box(bbox_min_position, bbox_max_position, ray.start_position, ray.direction);
ray_bbox_distances = max(ray_bbox_distances, 0.0); // clamp bbox distances above zero for the case we are inside

// update ray if there is an intersection
if (ray_bbox_distances.x < ray_bbox_distances.y)
{
    ray.start_distance = ray.start_distance + ray_bbox_distances.x;
    ray.start_position = ray.start_position + ray_bbox_distances.x * ray.direction;
    ray.end_distance   = ray.start_distance + ray_bbox_distances.y;
    ray.end_position   = ray.start_position + ray_bbox_distances.y * ray.direction;
    ray.span_distance  = ray_bbox_distances.y - ray_bbox_distances.x;
}
else
{
    #include "./discard_ray"
}