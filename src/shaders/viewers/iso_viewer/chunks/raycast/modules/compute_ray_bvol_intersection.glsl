
// Compute ray entry with bounding volume
for (ray.skip_count = 0; ray.skip_count < MAX_SKIP_COUNT; ray.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/sample_distmap_start
    if (block.occupied) break;   

    #include "./compute_ray_bvol_intersection/update_ray_start
    if (ray.start_distance > ray.end_distance) break;
}

// Refine ray start at current block
if (block.occupied)  
{
    #include "./compute_ray_bvol_intersection/refine_ray_start
}


// Compute ray exit with bounding volume
for (ray.skip_count = 0; ray.skip_count < MAX_SKIP_COUNT; ray.skip_count++) 
{
    #include "./compute_ray_bvol_intersection/sample_distmap_end
    if (block.occupied) break;

    #include "./compute_ray_bvol_intersection/update_ray_end
    if (ray.start_distance > ray.end_distance) break;
}

// Refine ray end at current block
if (block.occupied)  
{
    #include "./compute_ray_bvol_intersection/refine_ray_end
}


// Discard ray if no intersection with bounding volume
if (ray.start_distance > ray.end_distance)
{
    #include "./discard_ray"
}
