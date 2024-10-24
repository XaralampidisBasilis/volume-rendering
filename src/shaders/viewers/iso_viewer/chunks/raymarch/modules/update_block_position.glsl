

// update trace spatial data
trace.spacing = block.skipping;
trace.skipped += block.skipping;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * volume_inv_size;
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * volume_inv_spacing);
