// precompute invariant values outside the loop to avoid redundant memory access
float raycast_threshold = u_raycast.threshold;
float gradient_threshold = u_gradient.threshold * u_gradient.max_norm;
vec3 volume_size = u_volume.size;
vec3 volume_spacing = u_volume.spacing;
vec3 volume_inv_size = u_volume.inv_size;
vec3 volume_inv_spacing = u_volume.inv_spacing;
ivec3 occupancy_base_dimensions = u_occupancy.base_dimensions;
vec3 occupancy_base_spacing = u_occupancy.base_spacing;
int occupancy_max_skips = u_occupancy.max_skips;
int occupancy_lods = u_occupancy.lods;

// initialize ray and trace parameters
ray.intersected = false;
ray.origin = v_camera;
ray.direction = normalize(v_direction);
ray.global_min_position = vec3(0.0);
ray.global_max_position = vec3(volume_size);

// add small values to avoid numerical instabilities in  box boundaries
ray.global_min_position += volume_spacing * DECI_TOL;
ray.global_max_position -= volume_spacing * DECI_TOL;

// find global ray distances 
vec2 ray_global_distances = sdf_box_bounds(ray.global_min_position, ray.global_max_position, ray.origin);
ray_global_distances = max(ray_global_distances, 0.0); 
ray.global_min_distance = ray_global_distances.x;
ray.global_max_distance = ray_global_distances.y;
ray.global_max_depth = max(ray.global_max_distance - ray.global_min_distance, 0.0);

// find ray distances
vec2 ray_distances_box = intersect_box(ray.global_min_position, ray.global_max_position, ray.origin, ray.direction);
ray_distances_box = max(ray_distances_box, 0.0); 
ray.min_distance = ray_distances_box.x;
ray.max_distance = ray_distances_box.y;
ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);

// update trace 
trace.distance = ray.min_distance;
trace.position = ray.origin + ray.direction * trace.distance;
trace.texel = trace.position * volume_inv_size;
trace.coords = floor(trace.position * volume_inv_spacing);
trace.depth = trace.distance - ray.min_distance;