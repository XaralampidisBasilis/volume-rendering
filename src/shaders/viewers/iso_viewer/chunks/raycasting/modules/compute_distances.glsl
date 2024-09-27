// set ray bounding box
ray.box_min = mix(ray.box_min, u_occupancy.box_min, float(HAS_BBOX));
ray.box_max = mix(ray.box_max, u_occupancy.box_max, float(HAS_BBOX));

// intersect ray with bounding box
vec2 ray_distances = intersect_box(ray.box_min, ray.box_max, ray.origin, ray.direction);
ray_distances = max(ray_distances, 0.0); 
ray.min_distance = ray_distances.x;
ray.max_distance = ray_distances.y;

// reach ray with bounding box
vec2 box_distances = reach_box(ray.box_min, ray.box_max, ray.origin);
box_distances = max(box_distances, 0.0); 
ray.min_box_distance = box_distances.x;
ray.max_box_distance = box_distances.y;
