
// set ray bounding box
#if HAS_BBOX == 1  
    ray.global_min_position = u_occupancy.min_position;
    ray.global_max_position = u_occupancy.max_position;
#else  
    ray.global_min_position = vec3(0.0);
    ray.global_max_position = u_volume.size;
#endif // HAS_BBOX

// intersect ray with bounding box
vec2 ray_distances = intersect_box(ray.global_min_position, ray.global_max_position, ray.origin, ray.direction);
ray_distances = max(ray_distances, 0.0); 
ray.min_distance = ray_distances.x;
ray.max_distance = ray_distances.y;
ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);

// find global distances of ray with bounding box
vec2 ray_global_distances = sdf_box_bounds(ray.global_min_position, ray.global_max_position, ray.origin);
ray_global_distances = max(ray_global_distances, 0.0); 
ray.global_min_distance = ray_global_distances.x;
ray.global_max_distance = ray_global_distances.y;
ray.global_max_depth = max(ray.global_max_distance - ray.global_min_distance, 0.0);
