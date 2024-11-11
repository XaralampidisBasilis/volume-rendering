
// compute final occupied block bounds in model space
vec3 block_min_position = vec3(occumap.block_coords + 0);
vec3 block_max_position = vec3(occumap.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// scale occupancy block by half voxel
block_min_position -= u_volume.spacing;
block_max_position += u_volume.spacing; 

// compute the distance to get to the start of the occupied block
float ray_refine_distance = intersect_box_max(block_min_position, block_max_position, ray.start_position, -ray.step_direction);
ray_refine_distance = max(ray_refine_distance, ray.step_distance);  

// updata ray start distance and position
ray.start_distance -= ray_refine_distance;
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance; 
ray.span_distance = ray.end_distance - ray.start_distance;