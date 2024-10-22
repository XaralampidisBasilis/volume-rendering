
block.min_position = vec3(block.coords) * occumap.spacing;
block.max_position = block.min_position + occumap.spacing;
block.skipping = intersect_box_max(block.min_position, block.max_position, trace.position, ray.direction);

trace.spacing = block.skipping + ray.spacing;
trace.skipped += trace.spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * inv_volume_size;
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * inv_volume_spacing);
