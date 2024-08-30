/**
 * Computes the intersection bounds of a ray with an axis-aligned bounding box.
 *
 * @param box_min: Minimum coordinates of the occupancy box.
 * @param box_max: Maximum coordinates of the occupancy box.
 * @param ray_origin: Starting point of the ray.
 * @param ray_direction: Direction vector of the ray (should be normalized).
 * @return vec2: Returns the start and end distances for raycasting, ensuring non-negative bounds.
 */
vec2 compute_bounds
(
    in vec3 volume_size,
    in vec3 box_min, 
    in vec3 box_max, 
    in vec3 ray_origin, 
    in vec3 ray_direction
)
{
    box_min *= volume_size;
    box_max *= volume_size;

    // Intersect the box with the ray and compute the bounds.
    vec2 ray_bounds = intersect_box(box_min, box_max, ray_origin, ray_direction);

    // Ensure the bounds are non-negative; if the camera is inside the bounding box, start from zero.
    ray_bounds = max(ray_bounds, 0.0); 

    // Discard fragments if the ray does not intersect the box.
    if (ray_bounds.x > ray_bounds.y) discard;

    return ray_bounds;
}
