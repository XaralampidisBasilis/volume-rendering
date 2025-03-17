
// Set parameters
float ray_plane_distance;
bool has_intersected;

// Compute ray slices intersections
for (int n = 0; n < 3; n++)
{
    // Compute ray plane distance
    ray_plane_distance = intersect_plane(u_slices.hessian[n], camera.position, ray.direction);

    // Compute if intersection is acceptable
    has_intersected = u_slices.visible[n] && inside_closed(box.entry_distance, box.exit_distance, ray_plane_distance);

    // Compute ray end distance
    ray_plane_distance = (has_intersected) ? ray_plane_distance : box.exit_distance;
    ray.end_distance = min(ray.end_distance, ray_plane_distance);
}

// Compute ray based on intersections result
if (ray.start_distance < ray.end_distance)
{
    ray.span_distance = ray.end_distance - ray.start_distance;
}
else
{
    #include "./discard_ray"
}