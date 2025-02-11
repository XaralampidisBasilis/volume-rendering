
#if PRE_MARCHING_ENABLED == 1
#include "./compute_pre_march"
#endif

// start march at ray start
#include "./modules/start_block"

 for (int i = 0; i < u_rendering.max_block_count; i++) 
{
    #include "./modules/update_block"

    if (block.occupied)
    {
        mip.intensity = max(mip.intensity, block.max_intensity);

        // trace.distance = block.entry_distance;

        // for (int j = 0; j < u_rendering.max_cell_count; j++) 
        // {
        //     // Update trace distance
        //     trace.distance += ray.step_distance * (0.5 + random(trace.uvw));

        //     // Termination condition
        //     trace.terminated = trace.distance > block.exit_distance;
        //     if (trace.terminated) break;

        //     // Compute position
        //     trace.position = camera.position + ray.direction * trace.distance;
        //     trace.uvw = trace.position * u_intensity_map.inv_size;

        //     // Sample intensity map
        //     trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

        //     // Update maximum intensity projection
        //     mip.intensity = max(mip.intensity, trace.intensity);
        // }
    }  

    if (block.terminated) break;
}

// terminate march, compute intersection and gradient
#include "./modules/end_march"
