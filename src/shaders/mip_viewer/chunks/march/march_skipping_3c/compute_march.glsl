
#include "./modules/start_block"

for (int n = 0; n < u_rendering.max_block_count; n++) 
{
    #include "./modules/update_block"

    if (block.terminated)
    {
        break;
    }

    if (!block.occupied) 
    {
        // Update stats
        #if STATS_ENABLED == 1
        stats.num_skips += 1;
        #endif

        continue;
    }  

    #include "./modules/start_trace"

    for (int i = 0; i < u_rendering.max_cell_count; i++) 
    {
        // Compute trace position
        trace.distance += trace.distance_step;
        trace.position = camera.position + ray.direction * trace.distance;
        trace.uvw = trace.position * u_intensity_map.inv_size;

        // Sample intensity map
        trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

        // Update maximum intensity projection
        mip.intensity = max(mip.intensity, trace.intensity);

        if (trace.distance > block.exit_distance || mip.intensity == block.max_intensity) 
        {
            break;
        } 
    }
}   


// terminate march, compute intersection and gradient
#include "./modules/end_march"
