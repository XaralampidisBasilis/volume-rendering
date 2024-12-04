
// Compute ray entry with bounding volume
for (block.skip_count = 0; block.skip_count < u_rendering.max_skip_count; block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/update_block_start
    if (block.occupied) break;   

    #include "./compute_ray_bvol_intersection/update_ray_start
    if (ray.start_distance > ray.end_distance) break;
}


// Compute ray exit with bounding volume
for (block.skip_count; block.skip_count < u_rendering.max_skip_count; block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/update_block_end
    if (block.occupied) break;

    #include "./compute_ray_bvol_intersection/update_ray_end
    if (ray.start_distance > ray.end_distance) break;
}


// Discard ray if no intersection with bounding volume
if (ray.start_distance > ray.end_distance)
{
    #include "./discard_ray"
}
else 
{
    ray.span_distance = ray.end_distance - ray.start_distance;
}


