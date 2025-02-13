
trace.distance = ray.start_distance;
mip.intensity = 0.0;

for (int i = 0; i < 160; i++) 
{
    // Update trace position
    trace.distance += ray.step_distance * (4.0 + random(trace.uvw));
    trace.position = camera.position + ray.direction * trace.distance;
    trace.uvw = trace.position * u_intensity_map.inv_size;
    
    // Sample intensity map
    trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

    // Update maximum intensity projection
    mip.intensity = max(mip.intensity, trace.intensity);

    // Termination condition
    trace.terminated = trace.distance > ray.end_distance;

    // Update stats
    #if STATS_ENABLED == 1
    stats.num_fetches += 1;
    #endif

    if (trace.terminated) 
    {
        break;
    }  
}