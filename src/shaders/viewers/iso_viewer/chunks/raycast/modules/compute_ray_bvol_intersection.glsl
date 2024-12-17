
// Compute ray entry with bounding volume
block.step_coords = ivec3(0);
block.coords = ivec3((ray.start_position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);

for (int count = 0; count < u_rendering.max_skip_count; count++, block.skip_count++) 
{
    #include "./compute_ray_bvol_intersection_2/block_ray_start
    
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


// // Compute ray exit with bounding volume
// block.step_coords = ivec3(0);
// block.coords = ivec3((ray.end_position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);

// for (int count = 0; count < u_rendering.max_skip_count; count++, block.skip_count++) 
// {
//     #include "./compute_ray_bvol_intersection_2/block_ray_end

//     if (block.occupied) 
//     {
//         break;
//     }   

//     #include "./compute_ray_bvol_intersection_2/update_ray_end
    
//     if (ray.start_distance > ray.end_distance) 
//     {
//         break;
//     }
// }

// if (block.occupied)
// {
//     // #include "./compute_ray_bvol_intersection_2/refine_ray_end"
// }

// Discard ray if no intersection with bounding volume
if (ray.start_distance > ray.end_distance)
{
    #include "./discard_ray"
}
else 
{
    ray.span_distance = ray.end_distance - ray.start_distance;
}


