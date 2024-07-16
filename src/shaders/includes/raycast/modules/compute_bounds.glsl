/**
 * Computes the intersection bounds of a ray with an axis-aligned bounding box.
 *
 * @param u_occupancy: struct containing occupancy-related uniforms.
 * @param box_min: Minimum coordinates of the occypancy box.
 * @param box_max: Maximum coordinates of the occypancy box.
 * @param ray_start: Starting point of the ray.
 * @param ray_normal: Direction vector of the ray (should be normalized).
 * @return vec2: Returns the start and end distances for raycasting, ensuring non-negative bounds.
 */
vec2 compute_bounds(in uniforms_occupancy u_occupancy, in vec3 ray_start, in vec3 ray_normal)
{
    // intersect box with ray and compute the bounds
    vec2 ray_bounds = intersect_box(u_occupancy.box_min, u_occupancy.box_max, ray_start, ray_normal);
    
    // Ensure the bounds are non-negative, meaning if camera is inside the bounding box, then we start from zero
    ray_bounds = max(ray_bounds, 0.0); 

    // discard fragments the ray does not intersect the box
    if (ray_bounds.x > ray_bounds.y) discard;

    return ray_bounds;
}