// compute final occupied block bounds in model space
vec3 block_min_position = vec3(occumap.block_coords + 0);
vec3 block_max_position = vec3(occumap.block_coords + 1);
block_min_position *= occumap.spacing;
block_max_position *= occumap.spacing;

// make occupied block bigger by a voxel to include boundary voxels that are
// also occupied due to the linear filtering in the volume texture
block_min_position -= u_volume.spacing;
block_max_position += u_volume.spacing;

// compute the distance to get to the start of the occupied block
float ray_backstep_distance = intersect_box_max(block_min_position, block_max_position, ray.start_position, -ray.step_direction);
ray_backstep_distance += length(u_volume.spacing);

// updata ray start distance and position
ray.start_distance -= ray_backstep_distance;
ray.start_distance = max(ray.start_distance, ray.box_start_distance);
ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance; 
ray.span_distance = ray.end_distance - ray.start_distance;