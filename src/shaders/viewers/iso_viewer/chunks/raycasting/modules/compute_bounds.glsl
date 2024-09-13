// set ray bounding box
ray.box_min = mix(ray.box_min, u_occupancy.box_min, float(HAS_BBOX));
ray.box_max = mix(ray.box_max, u_occupancy.box_max, float(HAS_BBOX));

// intersect ray with bounding box
vec2 bounding_distance = intersect_box(ray.box_min, ray.box_max, ray.origin, ray.direction);
bounding_distance = max(bounding_distance, 0.0); 
ray.min_distance = bounding_distance.x;
ray.max_distance = bounding_distance.y;
