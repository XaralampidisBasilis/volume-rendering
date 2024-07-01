bool mono_resolution()
{
    // check if the current block is occupied
    bool occupied = occupied_block(u_occupancy, u_volume, sampler_occupancy, hit_position, ray_step, skip_steps);
    if (occupied) {
                
        // perform raycasting in the occupied block 
        bool hit = raycast_block(u_raycast, sampler_volume, ray_step, skip_steps, hit_position, hit_intensity);
        if (hit) 
            return true;
    } 

    // skip the specified number of steps and go to the end of the block
    hit_position += ray_step * skip_steps;
    n_step += skip_steps;
}