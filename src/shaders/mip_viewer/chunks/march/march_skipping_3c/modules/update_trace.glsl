
// Compute trace position
trace.distance += trace.distance_step;
trace.position = camera.position + ray.direction * trace.distance;
trace.uvw = trace.position * u_intensity_map.inv_size;

// Sample intensity map
trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

// Update maximum intensity projection
mip.intensity = max(mip.intensity, trace.intensity);