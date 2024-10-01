// set ray bounding box
ray.box_min = mix(ray.box_min, u_occupancy.box_min, float(HAS_BBOX));
ray.box_max = mix(ray.box_max, u_occupancy.box_max, float(HAS_BBOX));

// intersect ray with bounding box
vec2 ray_distances = intersect_box(ray.box_min, ray.box_max, ray.origin, ray.direction);
ray_distances = max(ray_distances, 0.0); 
ray.min_distance = ray_distances.x;
ray.max_distance = ray_distances.y;

// find ray bounding distances with bounding box
vec2 ray_bounding_distances = sdf_box_bounds(ray.box_min, ray.box_max, ray.origin);
ray_bounding_distances = max(ray_bounding_distances, 0.0); 
ray.min_min_distance = ray_bounding_distances.x;
ray.max_max_distance = ray_bounding_distances.y;

// compute depths
ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);
ray.max_max_depth = max(ray.max_max_distance - ray.min_min_distance, 0.0);
