
// Sample intensity map
trace.intensity = texture(u_textures.intensity_map, trace.uvw).r;

// Update maximum intensity projection
mip.intensity = max(mip.intensity, trace.intensity);

// Compute trace position
trace.distance += trace.distance_step;
trace.uvw = camera.uvw + ray.direction_uvw * trace.distance;

