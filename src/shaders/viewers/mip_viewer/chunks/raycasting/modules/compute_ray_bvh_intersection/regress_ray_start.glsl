occumap.block_coords = ivec3(ray.start_position * occumap.inv_spacing);

// compute final occupied block bounds in model space
vec3 block_min_position = vec3(occumap.block_coords + 0);
vec3 block_max_position = vec3(occumap.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// an occupied block is occupied also half a voxel outside due to trilinear filtering
block_min_position -= u_volume.spacing * 0.5;
block_max_position += u_volume.spacing * 0.5;

// compute the distance to get to the start of the occupied block
ray.start_distance = ray.box_start_distance + intersect_box_min(block_min_position, block_max_position, ray.box_start_position, ray.step_direction);
ray.start_distance -= u_volume.spacing_length * 2.0;  

// updata ray start distance and position
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.camera_position + ray.step_direction * ray.start_distance; 
ray.span_distance = ray.end_distance - ray.start_distance;