// set occupancy bounding box
ray.global_min_position = u_occupancy.min_position;
ray.global_max_position = u_occupancy.max_position;

// add small values to avoid numerical instabilities in bounding box boundaries
ray.global_min_position += volume_spacing * DECI_TOL;
ray.global_max_position -= volume_spacing * DECI_TOL;

// intersect ray with occupancy bounding box
vec2 ray_distances_bbox = intersect_box(ray.global_min_position, ray.global_max_position, ray.origin, ray.direction);
ray_distances_bbox = max(ray_distances_bbox, 0.0); 
ray.min_distance = ray_distances_bbox.x;
ray.max_distance = ray_distances_bbox.y;
ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);

// update trace spatial data
trace.distance = ray.min_distance;
trace.position = ray.origin + ray.direction * trace.distance;
trace.texel = trace.position * volume_inv_size;
trace.coords = floor(trace.position * volume_inv_spacing);
trace.depth = trace.distance - ray.min_distance;