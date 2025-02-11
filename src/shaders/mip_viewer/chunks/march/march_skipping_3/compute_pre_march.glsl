
trace.distance = ray.start_distance;
trace.position = ray.start_position;
mip.intensity = 0.0;

for (int i = 0; i < 120; i++) 
{
    // Update trace position
    float step_scale = 4.0 + random(trace.uvw);
    trace.distance += ray.step_distance * step_scale;
    trace.position = camera.position + ray.direction * trace.distance;
    trace.uvw = trace.position * u_intensity_map.inv_size;
    
    // Sample intensity map
    trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

    // Update maximum intensity projection
    mip.intensity = max(mip.intensity, trace.intensity);

    // Termination condition
    trace.terminated = trace.distance > ray.end_distance;

    if (trace.terminated) 
    {
        break;
    }  
}