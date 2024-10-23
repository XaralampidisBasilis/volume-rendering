float trace_backstep = length(occumap.spacing); // needed to avoid getting inside volume, dont know why
trace.skipped -= block.skipping;

// update trace spatial data
trace.distance -= trace_backstep;
trace.distance = max(trace.distance, ray.min_distance);
trace.position = ray.origin + ray.direction * trace.distance;
trace.texel = trace.position * volume_inv_size;
trace.coords = floor(trace.position * volume_inv_spacing);
trace.depth = 0.0;

// update ray spatial data
ray.min_distance = trace.distance;
ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);
