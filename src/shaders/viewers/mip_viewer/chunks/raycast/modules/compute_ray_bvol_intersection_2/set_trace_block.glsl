// Set ray
ray.min_value = 0.0;
ray.max_value = 0.0;

// Set trace
trace.distance = ray.start_distance;
trace.position = ray.start_position;

// Compute block coords
block.step_coords = ivec3(0);
block.coords = ivec3((trace.position + u_volume.spacing * 0.5) * u_extremap.inv_spacing);

