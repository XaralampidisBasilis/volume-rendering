trace.spacing = - ray.spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * volume_inv_size;
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * volume_inv_spacing);
