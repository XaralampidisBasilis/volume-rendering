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
    in vec3 ray_box_min, 
    in vec3 ray_box_max, 
    in vec3 ray_origin, 
    in vec3 ray_direction
)
{
    // Intersect the box with the ray and compute the bounds.
    vec2 ray_bounds = intersect_box(ray_box_min, ray_box_max, ray_origin, ray_direction);

    // Ensure the bounds are non-negative; if the camera is inside the bounding box, start from zero.
    ray_bounds = max(ray_bounds, 0.0); 

    return ray_bounds;
}
