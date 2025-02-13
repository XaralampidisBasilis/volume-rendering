
trace.distance = ray.start_distance;
trace.distance_step = ray.span_distance / float(u_rendering.max_count);
mip.intensity = 0.0;

for (int i = 0; i < u_rendering.max_count; i++) 
{
    // Compute trace position
    trace.distance += trace.distance_step * (0.5 + random(trace.uvw));
    trace.position = camera.position + ray.direction * trace.distance;
    trace.uvw = trace.position * u_intensity_map.inv_size;

    // Sample intensity map
    trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

    // Update maximum intensity projection
    mip.intensity = max(mip.intensity, trace.intensity);

    if (trace.distance > ray.end_distance) 
    {
        break;
    }  
}

trace.terminated = trace.distance > ray.end_distance;
