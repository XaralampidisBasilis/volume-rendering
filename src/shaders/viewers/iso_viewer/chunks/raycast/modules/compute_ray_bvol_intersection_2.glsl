
// Compute ray entry with bounding volume
#include "./compute_ray_bvol_intersection_2/set_block_ray_start

for (int count = 0; count < u_rendering.max_skip_count; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection_2/update_block
    
    if (block.occupied) 
    {
        break;
    }   

    #include "./compute_ray_bvol_intersection_2/update_ray_start
    
    if (ray.start_distance > ray.end_distance) 
    {
        break;
    }
}

if (block.occupied)
{
    #include "./compute_ray_bvol_intersection_2/refine_ray_start"
}


// Compute ray exit with bounding volume
#include "./compute_ray_bvol_intersection_2/set_block_ray_end

for (int count = 0; count < u_rendering.max_skip_count; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection_2/update_block

    if (block.occupied) 
    {
        break;
    }   

    #include "./compute_ray_bvol_intersection_2/update_ray_end
    
    if (ray.start_distance > ray.end_distance) 
    {
        break;
    }
}

if (block.occupied)
{
    #include "./compute_ray_bvol_intersection_2/refine_ray_end"
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


