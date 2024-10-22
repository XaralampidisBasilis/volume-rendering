
block.min_position = vec3(block.coords) * block.size;
block.max_position = block.min_position + block.size;
block.skip_depth = intersect_box_max(block.min_position, block.max_position, trace.position, ray.direction);

trace.spacing = block.skip_depth + spacing_delta;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * u_volume.inv_size;