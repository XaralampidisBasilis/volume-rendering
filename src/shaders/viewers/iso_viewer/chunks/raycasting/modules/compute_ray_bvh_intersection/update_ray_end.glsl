ray.skip_count++;

// compute block min and max positions in model space based on block coordinates
vec3 block_min_position = vec3(occumap.block_coords + 0) - MILLI_TOLERANCE;
vec3 block_max_position = vec3(occumap.block_coords + 1) + MILLI_TOLERANCE;
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// intersect ray with block to find the skip distance
ray.skip_distance = intersect_box_max(block_min_position, block_max_position, ray.end_position, -ray.step_direction);

// updata ray start distance and position
ray.end_distance -= ray.skip_distance;
ray.end_position = ray.origin_position + ray.step_direction * ray.end_distance; 
