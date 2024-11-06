// volume box 
ray.box_min_position = vec3(0.0);
ray.box_max_position = volume.size;

// shrink volume box by a small amount to avoid numerical instabilities in the boundary
ray.box_min_position += volume.spacing * MILLI_TOL;
ray.box_max_position -= volume.spacing * MILLI_TOL;

// compute rays bound distances with the volume box
vec2 ray_box_bounds = box_bounds(ray.box_min_position, ray.box_max_position, ray.origin_position);
ray.box_min_distance = ray_box_bounds.x;
ray.box_max_distance = ray_box_bounds.y;
