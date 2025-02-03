
ivec3 start_coords = ivec3(ray.start_position * u_intensity_map.inv_spacing);
ivec3 end_coords = ivec3(ray.end_position * u_intensity_map.inv_spacing);
ivec3 span_coords = abs(end_coords - start_coords);

ray.max_cell_count = sum(span_coords) - 2;
ray.max_cell_count = mmin(ray.max_cell_count, u_rendering.max_cell_count, MAX_CELL_COUNT);

ray.max_block_count = sum(span_coords / u_distance_map.sub_division) - 2;
ray.max_block_count = mmin(ray.max_block_count, u_rendering.max_block_count, MAX_BLOCK_COUNT);
