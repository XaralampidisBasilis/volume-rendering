
// compute block min and max positions in model space based on block coordinates
// make block a bit bigger in order to skip into the next block
vec3 block_min_position = vec3(occumap.block_coords + 0) - MILLI_TOLERANCE;
vec3 block_max_position = vec3(occumap.block_coords + 1) + MILLI_TOLERANCE;
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// intersect ray with block to find the skip distance
float ray_skip_distance = intersect_box_max(block_min_position, block_max_position, ray.start_position, ray.step_direction);
ray.skip_count++;

// updata ray start distance and position
ray.start_distance += ray_skip_distance;
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance; 
